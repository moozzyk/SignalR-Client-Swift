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

    private var url: URL
    private let options: HttpConnectionOptions
    private let transportFactory: TransportFactory
    private let logger: Logger

    private var transportDelegate: TransportDelegate?

    private var state: State
    private var transport: Transport?
    private var stopError: Error?

    public weak var delegate: ConnectionDelegate?
    public private(set) var connectionId: String?

    private enum State: String {
        case initial = "initial"
        case connecting = "connecting"
        case connected = "connected"
        case stopped = "stopped"
    }

    public convenience init(url: URL, options: HttpConnectionOptions = HttpConnectionOptions(), logger: Logger = NullLogger()) {
        self.init(url: url, options: options, transportFactory: DefaultTransportFactory(logger: logger), logger: logger)
    }

    init(url: URL, options: HttpConnectionOptions, transportFactory: TransportFactory, logger: Logger) {
        logger.log(logLevel: .debug, message: "HttpConnection init")
        connectionQueue = DispatchQueue(label: "SignalR.connection.queue")
        startDispatchGroup = DispatchGroup()

        self.url = url
        self.options = options
        self.transportFactory = transportFactory
        self.logger = logger
        self.state = .initial
    }

    deinit {
        logger.log(logLevel: .debug, message: "HttpConnection deinit")
    }

    public func start() {
        logger.log(logLevel: .info, message: "Starting connection")

        if changeState(from: .initial, to: .connecting) == nil {
            logger.log(logLevel: .error, message: "Starting connection failed - invalid state")
            // the connection is already in use so the startDispatchGroup should not be touched to not affect it
            failOpenWithError(error: SignalRError.invalidState, changeState: false, leaveStartDispatchGroup: false)
            return
        }

        startDispatchGroup.enter()

        if options.skipNegotiation {
            transport = try! self.transportFactory.createTransport(availableTransports: [TransportDescription(transportType: TransportType.webSockets, transferFormats: [TransferFormat.text, TransferFormat.binary])])
            startTransport(connectionId: nil)
        } else {
            negotiate(accessToken: nil) { negotiationResponse in
                do {
                    self.transport = try self.transportFactory.createTransport(availableTransports: negotiationResponse.availableTransports)
                } catch {
                    self.logger.log(logLevel: .error, message: "Creating transport failed: \(error)")
                    self.failOpenWithError(error: error, changeState: true)
                    return
                }

                self.startTransport(connectionId: negotiationResponse.connectionId)
            }
        }
    }

    private func negotiate(accessToken: String?, negotiateDidComplete: @escaping (NegotiationResponse) -> Void) {
        if let accessToken = accessToken {
            logger.log(logLevel: .debug, message: "Overriding accessToken")
            options.accessTokenProvider = { accessToken }
        }

        var negotiateUrl = self.url
        negotiateUrl.appendPathComponent("negotiate")

        let httpClient = options.httpClientFactory(options)
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

                do {
                    let payload = httpResponse.contents
                    self.logger.log(logLevel: .debug, message: "Negotiate response: \(payload != nil ? String(data: payload!, encoding: .utf8) ?? "(nil)" : "(nil)")")

                    switch try NegotiationPayloadParser.parse(payload: payload) {
                    case let redirection as Redirection:
                        self.logger.log(logLevel: .debug, message: "Negotiate redirects to \(redirection.url)")
                        self.url = redirection.url
                        self.negotiate(accessToken: redirection.accessToken, negotiateDidComplete: negotiateDidComplete)
                    case let negotiationResponse as NegotiationResponse:
                        self.logger.log(logLevel: .debug, message: "Negotiation response received")
                        negotiateDidComplete(negotiationResponse)
                    default:
                        throw SignalRError.invalidNegotiationResponse(message: "internal error - unexpected negotiation payload")
                    }
                } catch {
                    self.logger.log(logLevel: .error, message: "Parsing negotiate response failed: \(error)")
                    self.failOpenWithError(error: error, changeState: true)
                }
            } else {
                self.logger.log(logLevel: .error, message: "HTTP request error. statusCode: \(httpResponse.statusCode)\ndescription:\(httpResponse.contents != nil ? String(data: httpResponse.contents!, encoding: .utf8) ?? "(nil)" : "(nil)")")
                self.failOpenWithError(error: SignalRError.webError(statusCode: httpResponse.statusCode), changeState: true)
            }
        }
    }

    private func startTransport(connectionId: String?) {
        // connection is being stopped even though start has not finished yet
        if (self.state != .connecting) {
            self.logger.log(logLevel: .info, message: "Connection closed during negotiate")
            self.failOpenWithError(error: SignalRError.connectionIsBeingClosed, changeState: false)
            return
        }

        let startUrl = self.createStartUrl(connectionId: connectionId)
        self.transportDelegate = ConnectionTransportDelegate(connection: self, connectionId: connectionId)
        self.transport!.delegate = self.transportDelegate
        self.transport!.start(url: startUrl, options: self.options)
    }

    private func createStartUrl(connectionId: String?) -> URL {
        if connectionId == nil {
            return self.url
        }
        var urlComponents = URLComponents(url: self.url, resolvingAgainstBaseURL: false)!
        var queryItems = (urlComponents.queryItems ?? []) as [URLQueryItem]
        queryItems.append(URLQueryItem(name: "id", value: connectionId))
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }

    private func failOpenWithError(error: Error, changeState: Bool, leaveStartDispatchGroup: Bool = true) {
        if changeState {
            _ = self.changeState(from: nil, to: .stopped)
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
        if state != .connected {
            logger.log(logLevel: .error, message: "Sending data failed - connection not in the 'connected' state")
            sendDidComplete(SignalRError.invalidState)
            return
        }
        transport!.send(data: data, sendDidComplete: sendDidComplete)
    }

    public func stop(stopError: Error? = nil) {
        logger.log(logLevel: .info, message: "Stopping connection")

        let previousState = self.changeState(from: nil, to: .stopped)
        if previousState == .stopped {
            logger.log(logLevel: .info, message: "Connection already stopped")
            return
        }

        if previousState == .initial {
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

    fileprivate func transportDidOpen(connectionId: String?) {
        logger.log(logLevel: .info, message: "Transport started")

        let previousState = changeState(from: .connecting, to: .connected)

        logger.log(logLevel: .debug, message: "Leaving startDispatchGroup (\(#function): \(#line))")
        startDispatchGroup.leave()
        if  previousState != nil {
            logger.log(logLevel: .debug, message: "Invoking connectionDidOpen")
            self.connectionId = connectionId
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

    fileprivate func transportDidClose(_ error: Error?) {
        logger.log(logLevel: .info, message: "Transport closed")

        let previousState = changeState(from: nil, to: .stopped)
        logger.log(logLevel: .debug, message: "Previous state \(previousState!)")

        if previousState == .connecting {
            logger.log(logLevel: .debug, message: "Leaving startDispatchGroup (\(#function): \(#line))")
            // unblock the dispatch group if transport closed when starting (likely due to an error)
            startDispatchGroup.leave()

            logger.log(logLevel: .debug, message: "Invoking connectionDidFailToOpen")
            Util.dispatchToMainThread {
                self.delegate?.connectionDidFailToOpen(error: self.stopError ?? error!)
            }
        } else {
            logger.log(logLevel: .debug, message: "Invoking connectionDidClose (\(#function): \(#line))")

            self.connectionId = nil

            Util.dispatchToMainThread {
                self.delegate?.connectionDidClose(error: self.stopError ?? error)
            }
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
    private let connectionId: String?

    fileprivate init(connection: HttpConnection!, connectionId: String?) {
        self.connection = connection
        self.connectionId = connectionId
    }

    public func transportDidOpen() {
        connection?.transportDidOpen(connectionId: connectionId)
    }

    public func transportDidReceiveData(_ data: Data) {
        connection?.transportDidReceiveData(data)
    }

    public func transportDidClose(_ error: Error?) {
        connection?.transportDidClose(error)
    }
}
