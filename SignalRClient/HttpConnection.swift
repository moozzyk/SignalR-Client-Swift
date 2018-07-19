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

    public weak var delegate: ConnectionDelegate!

    private enum State {
        case initial
        case connecting
        case connected
        case stopped
    }

    public init(url: URL, options: HttpConnectionOptions = HttpConnectionOptions()) {
        connectionQueue = DispatchQueue(label: "SignalR.connection.queue")
        startDispatchGroup = DispatchGroup()

        self.url = url
        self.options = options
        self.state = State.initial
        self.transportDelegate = ConnectionTransportDelegate(connection: self)
    }

    public func start(transport: Transport? = nil) {
        if changeState(from: State.initial, to: State.connecting) == nil {
            failOpenWithError(error: SignalRError.invalidState, changeState: false)
            return;
        }

        startDispatchGroup.enter()

        // TODO: negotiate not needed if the user explicitly asks for WebSockets
        let httpClient = DefaultHttpClient(options: options)

        var negotiateUrl = self.url
        negotiateUrl.appendPathComponent("negotiate");

        httpClient.post(url: negotiateUrl) {httpResponse, error in
            if error != nil {
                print(error.debugDescription)
                self.startDispatchGroup.leave()

                self.failOpenWithError(error: error!, changeState: true)
                return
            }

            guard let httpResponse = httpResponse else {
                self.failOpenWithError(error: SignalRError.invalidNegotiationResponse(message: "negotiate returned nil httpResponse."), changeState: true)
                return
            }

            if httpResponse.statusCode == 200 {
                // connection is being stopped even though start has not finished yet
                if (self.state != State.connecting) {
                    self.startDispatchGroup.leave()
                    self.failOpenWithError(error: SignalRError.connectionIsBeingClosed, changeState: false)
                    return
                }

                let negotiationResponse: NegotiationResponse
                do {
                    negotiationResponse = try NegotiationResponse.parse(payload: httpResponse.contents)
                } catch {
                    self.failOpenWithError(error: error, changeState: true)
                    return
                }

                let startUrl = self.createStartUrl(connectionId: negotiationResponse.connectionId)

                self.transport = transport ?? WebsocketsTransport()
                self.transport!.delegate = self.transportDelegate
                self.transport!.start(url: startUrl, options: self.options)
            }
            else {
                self.startDispatchGroup.leave()
                print("HTTP request error. statusCode: \(httpResponse.statusCode)\ndescription: \(String(data: (httpResponse.contents)!, encoding: .utf8)!)")
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
        if state != State.connected {
            sendDidComplete(SignalRError.invalidState)
            return
        }
        transport!.send(data: data, sendDidComplete: sendDidComplete)
    }

    public func stop(stopError: Error? = nil) {
        if state == State.stopped {
            return
        }

        let previousState = self.changeState(from: nil, to: State.stopped)
        if previousState == State.initial {
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
                Util.dispatchToMainThread {
                    self.delegate?.connectionDidClose(error: stopError)
                }
            }
        }
    }

    fileprivate func transportDidOpen() {
        let previousState = self.changeState(from: nil, to: State.connected)

        assert(previousState == State.connecting)

        self.startDispatchGroup.leave()

        Util.dispatchToMainThread {
            self.delegate?.connectionDidOpen(connection: self)
        }
    }

    fileprivate func transportDidReceiveData(_ data: Data) {
        Util.dispatchToMainThread {
            self.delegate?.connectionDidReceiveData(connection: self, data: data)
        }
    }

    fileprivate func transportDidClose(_ error: Error?) {
        _ = self.changeState(from: nil, to: State.stopped)

        connectionQueue.async {
            // wait in case the transport failed immediately after being started to avoid
            // calling connectionDidClose before connectionDidOpen
            self.startDispatchGroup.wait()
            Util.dispatchToMainThread {
                self.delegate?.connectionDidClose(error: self.stopError ?? error)
            }
        }
    }

    private func changeState(from: State?, to: State!) -> State? {
        var previousState: State? = nil

        connectionQueue.sync {
            if from == nil || from == state {
                previousState = state
                state = to
            }
        }

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
