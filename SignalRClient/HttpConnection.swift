//
//  Connection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HttpConnection: Connection {
    private let connectionQueue: DispatchQueue
    private let startDispatchGroup: DispatchGroup

    private var transportDelegate: TransportDelegate?

    private var state: State
    private var url: URL
    private var transport: Transport?
    private let options: HttpConnectionOptions
    private var stopError: Error?
    private let logger: Logger

    public weak var delegate: ConnectionDelegate!

    private enum State: String {
        case initial = "initial"
        case connecting = "connecting"
        case connected = "connected"
        case stopped = "stopped"
    }

    public init(url: URL, options: HttpConnectionOptions = HttpConnectionOptions(), logger: Logger = NullLogger()) {
        connectionQueue = DispatchQueue(label: "SignalR.connection.queue")
        startDispatchGroup = DispatchGroup()

        self.url = url
        self.options = options
        self.logger = logger
        self.state = State.initial
        self.transportDelegate = ConnectionTransportDelegate(connection: self)
    }

    public func start(transport: Transport? = nil) {
        logger.log(logLevel: LogLevel.info, message: "Starting connection")
        if changeState(from: State.initial, to: State.connecting) == nil {
            logger.log(logLevel: LogLevel.error, message: "Starting connection failed - invalid state")
            failOpenWithError(error: SignalRError.invalidState, changeState: false)
            return;
        }

        startDispatchGroup.enter()

        // TODO: negotiate not needed if the user explicitly asks for WebSockets
        let httpClient = options.httpClientFactory(options)

        var negotiateUrl = self.url
        negotiateUrl.appendPathComponent("negotiate")

        httpClient.post(url: negotiateUrl) {httpResponse, error in
            if let e = error {
                self.logger.log(logLevel: LogLevel.error, message: "Negotiate failed due to: \(e))")

                self.startDispatchGroup.leave()

                self.failOpenWithError(error: e, changeState: true)
                return
            }

            guard let httpResponse = httpResponse else {
                self.logger.log(logLevel: LogLevel.error, message: "Negotiate returned (nil) httpResponse")
                self.failOpenWithError(error: SignalRError.invalidNegotiationResponse(message: "negotiate returned nil httpResponse."), changeState: true)
                return
            }

            if httpResponse.statusCode == 200 {
                self.logger.log(logLevel: LogLevel.debug, message: "Negotiate completed with OK status code")

                // connection is being stopped even though start has not finished yet
                if (self.state != State.connecting) {
                    self.logger.log(logLevel: LogLevel.info, message: "Connection closed during negotiate")
                    self.startDispatchGroup.leave()
                    self.failOpenWithError(error: SignalRError.connectionIsBeingClosed, changeState: false)
                    return
                }

                let negotiationResponse: NegotiationResponse
                do {
                    let payload = httpResponse.contents
                    self.logger.log(logLevel: LogLevel.debug, message: "Negotiate response: \(payload != nil ? String(data: payload!, encoding: .utf8) ?? "(nil)" : "(nil)")")
                    negotiationResponse = try NegotiationResponse.parse(payload: payload)
                } catch {
                    self.logger.log(logLevel: LogLevel.error, message: "Parsing negotiate response failed: \(error)")
                    self.failOpenWithError(error: error, changeState: true)
                    return
                }

                let startUrl = self.createStartUrl(connectionId: negotiationResponse.connectionId)

                self.transport = transport ?? WebsocketsTransport(logger: self.logger)
                self.transport!.delegate = self.transportDelegate
                self.transport!.start(url: startUrl, options: self.options)
            } else {
                self.logger.log(logLevel: LogLevel.error, message: "HTTP request error. statusCode: \(httpResponse.statusCode)\ndescription:\(httpResponse.contents != nil ? String(data: httpResponse.contents!, encoding: .utf8) ?? "(nil)" : "(nil)")")
                self.startDispatchGroup.leave()
                self.failOpenWithError(error: SignalRError.webError(statusCode: httpResponse.statusCode), changeState: true)
            }
        }
    }

    private func createStartUrl(connectionId: String) -> URL {
        let urlComponents = URLComponents(url: self.url, resolvingAgainstBaseURL: false)!
        var queryItems = (urlComponents.queryItems ?? []) as [URLQueryItem]
        queryItems.append(URLQueryItem(name: "id", value: connectionId))
        return urlComponents.url!
    }

    private func failOpenWithError(error: Error, changeState: Bool) {
        if changeState {
            _ = self.changeState(from: nil, to: State.stopped)
        }

        Util.dispatchToMainThread {
            self.delegate?.connectionDidFailToOpen(error: error)
        }
    }

    public func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
        logger.log(logLevel: LogLevel.debug, message: "Sending data")
        if state != State.connected {
            logger.log(logLevel: LogLevel.error, message: "Sending data failed - connection not in the 'connected' state")
            sendDidComplete(SignalRError.invalidState)
            return
        }
        transport!.send(data: data, sendDidComplete: sendDidComplete)
    }

    public func stop(stopError: Error? = nil) {
        logger.log(logLevel: LogLevel.info, message: "Stopping connection")
        if state == State.stopped {
            logger.log(logLevel: LogLevel.warning, message: "Connection already stopped")
            return
        }

        let previousState = self.changeState(from: nil, to: State.stopped)
        if previousState == State.initial {
            logger.log(logLevel: LogLevel.warning, message: "Connection not yest started")
            return
        }

        connectionQueue.async {
            self.startDispatchGroup.wait()
            // the transport can be nil if connection was stopped immediately after starting
            // in this case we need to call connectionDidClose ourselves
            if let t = self.transport {
                self.stopError = stopError
                t.close()
            } else {
                self.logger.log(logLevel: LogLevel.debug, message: "Connection being stopped before transport initialized")

                Util.dispatchToMainThread {
                    self.delegate?.connectionDidClose(error: stopError)
                }
            }
        }
    }

    fileprivate func transportDidOpen() {
        logger.log(logLevel: LogLevel.info, message: "Transport started")

        let previousState = self.changeState(from: nil, to: State.connected)

        assert(previousState == State.connecting)

        self.startDispatchGroup.leave()

        Util.dispatchToMainThread {
            self.delegate?.connectionDidOpen(connection: self)
        }
    }

    fileprivate func transportDidReceiveData(_ data: Data) {
        logger.log(logLevel: LogLevel.debug, message: "Received data from transport")
        Util.dispatchToMainThread {
            self.delegate?.connectionDidReceiveData(connection: self, data: data)
        }
    }

    fileprivate func transportDidClose(_ error: Error?) {
        logger.log(logLevel: LogLevel.info, message: "Transport closed")

        let previousState = self.changeState(from: nil, to: State.stopped)

        connectionQueue.async {
            if previousState == State.connecting {
                self.logger.log(logLevel: LogLevel.debug, message: "Unblocking startDispatch group")
                // unblock the dispatch group when transport close when starting (likely due to an error)
                self.startDispatchGroup.leave()
            } else {
                // wait in case the transport failed immediately after being started to avoid
                // calling connectionDidClose before connectionDidOpen
                self.startDispatchGroup.wait()
            }
            Util.dispatchToMainThread {
                self.delegate?.connectionDidClose(error: self.stopError ?? error)
            }
        }
    }

    private func changeState(from: State?, to: State) -> State? {
        var previousState: State? = nil

        logger.log(logLevel: LogLevel.debug, message: "Attempting to chage state from: '\(from?.rawValue ?? "(nil)")' to: '\(to)'")
        connectionQueue.sync {
            if from == nil || from == state {
                previousState = state
                state = to
            }
        }
        logger.log(logLevel: LogLevel.debug, message: "Changing state to: '\(state)' \(previousState == nil ? "failed" : "succeeded")")

        return previousState
    }
}

public class ConnectionTransportDelegate: TransportDelegate {
    private weak var connection: HttpConnection?

    fileprivate init(connection: HttpConnection!) {
        self.connection = connection
    }

    public func transportDidOpen() {
        connection?.transportDidOpen()
    }

    public func transportDidReceiveData(_ data: Data) {
        connection?.transportDidReceiveData(data)
    }

    public func transportDidClose(_ error: Error?) {
        connection?.transportDidClose(error)
    }
}
