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
        logger.log(logLevel: .info, message: "Starting connection")

        if changeState(from: State.initial, to: State.connecting) == nil {
            logger.log(logLevel: .error, message: "Starting connection failed - invalid state")
            // the connection is already in use so the startDispatchGroup should not be touched to not affect it
            failOpenWithError(error: SignalRError.invalidState, changeState: false, leaveStartDispatchGroup: false)
            return;
        }

        startDispatchGroup.enter()

        // TODO: negotiate not needed if the user explicitly asks for WebSockets
        let httpClient = options.httpClientFactory(options)

        var negotiateUrl = self.url
        negotiateUrl.appendPathComponent("negotiate")

        httpClient.post(url: negotiateUrl) {httpResponse, error in
            if let e = error {
                self.logger.log(logLevel: .error, message: "Negotiate failed due to: \(e))")
                self.failOpenWithError(error: e, changeState: true)
                return
            }

            guard let httpResponse = httpResponse else {
                self.logger.log(logLevel: .error, message: "Negotiate returned (nil) httpResponse")
                self.failOpenWithError(error: SignalRError.invalidNegotiationResponse(message: "negotiate returned nil httpResponse."), changeState: true)
                return
            }

            if httpResponse.statusCode == 200 {
                self.logger.log(logLevel: .debug, message: "Negotiate completed with OK status code")

                let negotiationResponse: NegotiationResponse
                do {
                    let payload = httpResponse.contents
                    self.logger.log(logLevel: .debug, message: "Negotiate response: \(payload != nil ? String(data: payload!, encoding: .utf8) ?? "(nil)" : "(nil)")")
                    negotiationResponse = try NegotiationResponse.parse(payload: payload)
                } catch {
                    self.logger.log(logLevel: .error, message: "Parsing negotiate response failed: \(error)")
                    self.failOpenWithError(error: error, changeState: true)
                    return
                }

                // connection is being stopped even though start has not finished yet
                if (self.state != State.connecting) {
                    self.logger.log(logLevel: .info, message: "Connection closed during negotiate")
                    self.failOpenWithError(error: SignalRError.connectionIsBeingClosed, changeState: false)
                    return
                }

                let startUrl = self.createStartUrl(connectionId: negotiationResponse.connectionId)

                self.transport = transport ?? WebsocketsTransport(logger: self.logger)
                self.transport!.delegate = self.transportDelegate
                self.transport!.start(url: startUrl, options: self.options)
            } else {
                self.logger.log(logLevel: .error, message: "HTTP request error. statusCode: \(httpResponse.statusCode)\ndescription:\(httpResponse.contents != nil ? String(data: httpResponse.contents!, encoding: .utf8) ?? "(nil)" : "(nil)")")
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

    private func failOpenWithError(error: Error, changeState: Bool, leaveStartDispatchGroup: Bool = true) {
        if changeState {
            _ = self.changeState(from: nil, to: State.stopped)
        }

        if leaveStartDispatchGroup {
            logger.log(logLevel: .debug, message: "Leaving startDispatchGroup (\(#function): \(#line))")
            startDispatchGroup.leave()
        }

        logger.log(logLevel: .debug, message: "Invoking connectionDidFailToOpen")
        Util.dispatchToMainThread {
            self.delegate?.connectionDidFailToOpen(error: error)
        }
    }

    public func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
        logger.log(logLevel: .debug, message: "Sending data")
        if state != State.connected {
            logger.log(logLevel: .error, message: "Sending data failed - connection not in the 'connected' state")
            sendDidComplete(SignalRError.invalidState)
            return
        }
        transport!.send(data: data, sendDidComplete: sendDidComplete)
    }

    public func stop(stopError: Error? = nil) {
        logger.log(logLevel: .info, message: "Stopping connection")

        let previousState = self.changeState(from: nil, to: State.stopped)
        if previousState == State.stopped {
            logger.log(logLevel: .info, message: "Connection already stopped")
            return
        }

        if previousState == State.initial {
            logger.log(logLevel: .warning, message: "Connection not yet started")
            return
        }

        self.startDispatchGroup.wait()
        
        // The transport can be nil if connection was stopped immediately after starting
        // or failed to start. In this case we need to call connectionDidClose ourselves.
        if let t = transport {
            self.stopError = stopError
            t.close()
        } else {
            logger.log(logLevel: .debug, message: "Connection being stopped before transport initialized")
            logger.log(logLevel: .debug, message: "Invoking connectionDidClose (\(#function): \(#line))")
            Util.dispatchToMainThread {
                self.delegate?.connectionDidClose(error: stopError)
            }
        }
    }

    fileprivate func transportDidOpen() {
        logger.log(logLevel: .info, message: "Transport started")

        let previousState = changeState(from: State.connecting, to: State.connected)

        logger.log(logLevel: .debug, message: "Leaving startDispatchGroup (\(#function): \(#line))")
        startDispatchGroup.leave()
        if  previousState != nil {
            logger.log(logLevel: .debug, message: "Invoking connectionDidOpen")
            Util.dispatchToMainThread {
                self.delegate?.connectionDidOpen(connection: self)
            }
        } else {
            logger.log(logLevel: .debug, message: "Connection is being stopped while the transport is starting")
        }
    }

    fileprivate func transportDidReceiveData(_ data: Data) {
        logger.log(logLevel: .debug, message: "Received data from transport")
        Util.dispatchToMainThread {
            self.delegate?.connectionDidReceiveData(connection: self, data: data)
        }
    }

    // TODO: verify if close can be called before/without open (e.g. in if websockets transport cannot be started)
    fileprivate func transportDidClose(_ error: Error?) {
        logger.log(logLevel: .info, message: "Transport closed")

        let previousState = changeState(from: nil, to: State.stopped)
        logger.log(logLevel: .debug, message: "Previous state \(previousState!)")

        if previousState == State.connecting {
            logger.log(logLevel: .debug, message: "Leaving startDispatchGroup (\(#function): \(#line))")
            // unblock the dispatch group if transport closed when starting (likely due to an error)
            startDispatchGroup.leave()
        }

        logger.log(logLevel: .debug, message: "Invoking connectionDidClose (\(#function): \(#line))")
        Util.dispatchToMainThread {
            self.delegate?.connectionDidClose(error: self.stopError ?? error)
        }
    }

    private func changeState(from: State?, to: State) -> State? {
        var previousState: State? = nil

        logger.log(logLevel: .debug, message: "Attempting to chage state from: '\(from?.rawValue ?? "(nil)")' to: '\(to)'")
        connectionQueue.sync {
            if from == nil || from == state {
                previousState = state
                state = to
            }
        }
        logger.log(logLevel: .debug, message: "Changing state to: '\(to)' \(previousState == nil ? "failed" : "succeeded")")

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
