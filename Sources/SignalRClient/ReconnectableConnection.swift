//
//  ReconnectableConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import Foundation

internal class ReconnectableConnection: Connection {
    private let connectionQueue = DispatchQueue(label: "SignalR.reconnection.queue")
    private let connectionDispatchGroup = DispatchGroup()

    private let connectionFactory: () -> Connection
    private let reconnectPolicy: ReconnectPolicy
    private let logger: Logger

    private var underlyingConnection: Connection
    private var wrappedDelegate: ConnectionDelegate?
    private var state = State.disconnected
    private var failedAttemptsCount: Int = 0
    private var reconnectStartTime: Date = Date()

    private enum State: String {
        case disconnected = "disconnected"
        case starting = "starting"
        case reconnecting = "reconnecting"
        case running = "running"
        case stopping = "stopping"
    }

    weak var delegate: ConnectionDelegate?
    var connectionId: String? {
        return underlyingConnection.connectionId
    }

    init(connectionFactory: @escaping () -> Connection, reconnectPolicy: ReconnectPolicy, logger: Logger) {
        self.connectionFactory = connectionFactory
        self.reconnectPolicy = reconnectPolicy
        self.logger = logger
        // TODO: use sentinel?
        self.underlyingConnection = connectionFactory()
    }

    func start() {
        if changeState(from:[.disconnected], to: .starting) != nil {
            startInternal()
        } else {
            // TODO: fail vs. ignore?
        }
    }

    func send(data: Data, sendDidComplete: (Error?) -> Void) {
        // TODO: do not send during reconnect. buffer?
        underlyingConnection.send(data: data, sendDidComplete: sendDidComplete)
    }

    func stop(stopError: Error?) {
        _ = changeState(from: nil, to: .stopping)
        underlyingConnection.stop(stopError: stopError)
    }

    private func startInternal() {
        var shouldStart = false
        connectionQueue.sync {
            shouldStart = state == .starting || state == .reconnecting
        }

        if (!shouldStart) {
            return
        }

        // likely does not have to recreated each time - the only state is `self`
        wrappedDelegate = ReconnectableConnectionDelegate(connection: self)
        underlyingConnection = connectionFactory()
        underlyingConnection.delegate = wrappedDelegate
        underlyingConnection.start()
    }

    private func changeState(from: [State]?, to: State) -> State? {
        var previousState: State? = nil
        connectionQueue.sync {
            if from?.contains(self.state) ?? true {
                previousState = self.state
                state = to
            }
        }
        return previousState
    }

    private func restartConnection(error: Error?) {
        if state == .starting || state == .reconnecting {
            let retryContext = updateAndCreateRetryContext(error: error)
            let nextAttemptInterval = reconnectPolicy.nextAttemptInterval(retryContext: retryContext)
            if nextAttemptInterval != .never {
                DispatchQueue.main.asyncAfter(deadline: .now() + nextAttemptInterval) {
                    self.startInternal()
                }
                if (retryContext.failedAttemptsCount == 0) {
                    delegate?.connectionWillReconnect(error: retryContext.error)
                }
                return
            }
        }

        let previousState = changeState(from: nil, to: .stopping)
        if previousState == .starting {
            delegate?.connectionDidFailToOpen(error: error ?? SignalRError.invalidOperation(message: "Opening connection failed"))
        } else if previousState == .reconnecting {
            delegate?.connectionDidClose(error: error)
        }

        // TODO: how to reset the state to not break things?
        // _ = changeState(from: nil, to: .disconnected)
    }

    private func updateAndCreateRetryContext(error: Error?) -> RetryContext {
        var attemptsCount = -1
        var startTime = Date()
        connectionQueue.sync {
            attemptsCount = self.failedAttemptsCount
            if attemptsCount == 0 {
                self.reconnectStartTime = Date()
            }
            startTime = self.reconnectStartTime
            self.reconnectStartTime += 1
        }

        if error == nil {
            // TODO: log - this should not happen
        }

        let error = error ?? SignalRError.invalidOperation(message: "Unexpected error.")
        return RetryContext(failedAttemptsCount: attemptsCount, reconnectStartTime: startTime, error: error)
    }

    private func resetRetryAttempts() {
        connectionQueue.sync {
            self.failedAttemptsCount = 0
            // no need to reset start time - it will be set next time reconnect happens
        }
    }

    private class ReconnectableConnectionDelegate: ConnectionDelegate {
        private weak var connection: ReconnectableConnection?

        init(connection: ReconnectableConnection) {
            self.connection = connection
        }

        func connectionDidOpen(connection: Connection) {
            guard let unwrappedConnection = self.connection else {
                return
            }
            unwrappedConnection.resetRetryAttempts()
            let previousState = unwrappedConnection.changeState(from: [.starting, .reconnecting], to: .running)
            if previousState == .starting {
                unwrappedConnection.delegate?.connectionDidOpen(connection: connection)
            } else if previousState == .reconnecting {
                // TODO: reset the attempt counter here
                unwrappedConnection.delegate?.connectionDidReconnect()
            } else {
                // TODO: log internal error
                // stop with error?
                // use dispatchGroup to block stop while reconnecting/starting
            }
        }

        func connectionDidFailToOpen(error: Error) {
            connection?.restartConnection(error: error)
        }

        func connectionDidReceiveData(connection: Connection, data: Data) {
            self.connection?.delegate?.connectionDidReceiveData(connection: connection, data: data)
        }

        func connectionDidClose(error: Error?) {
            guard let unwrappedConnection = self.connection else {
                return
            }
            let previousState = unwrappedConnection.changeState(from: [.running], to: .reconnecting)
            if previousState != nil {
                connection?.restartConnection(error: error)
            } else {
                // TODO: this is assuming that the state is .stopping which might not be correct
                unwrappedConnection.delegate?.connectionDidClose(error: error)
            }
        }
    }
}
