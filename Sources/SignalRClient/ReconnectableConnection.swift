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
            // TODO: fail
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
            let nextAttemptInterval = reconnectPolicy.nextAttemptInterval()
            if nextAttemptInterval != .never {
                DispatchQueue.main.asyncAfter(deadline: .now() + nextAttemptInterval) {
                    self.startInternal()
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

    private class ReconnectableConnectionDelegate: ConnectionDelegate {
        private weak var connection: ReconnectableConnection?

        init(connection: ReconnectableConnection) {
            self.connection = connection
        }

        func connectionDidOpen(connection: Connection) {
            guard let unwrappedConnection = self.connection else {
                return
            }

            let previousState = unwrappedConnection.changeState(from: [.starting, .reconnecting], to: .running)
            if previousState == .starting {
                unwrappedConnection.delegate?.connectionDidOpen(connection: connection)
            } else if previousState == .reconnecting {
                // TODO: invoke delegate?.connectionDidReconnect. (does it need to take connection)?
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
                // TODO: log state
                unwrappedConnection.delegate?.connectionDidClose(error: error)
            }
        }
    }
}
