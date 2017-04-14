//
//  Connection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class Connection: SocketConnection {
    private let connectionQueue: DispatchQueue
    private let startDispatchGroup: DispatchGroup

    private var transportDelegate: TransportDelegate?

    private var state: State
    private let url: URL
    private var query: String
    private var transport: Transport?

    public weak var delegate: SocketConnectionDelegate!

    private enum State {
        case initial
        case connecting
        case connected
        case stopped
    }

    public init(url: URL, query: String?) {
        connectionQueue = DispatchQueue(label: "SignalR.connection.queue")
        startDispatchGroup = DispatchGroup()

        self.url = url
        self.state = State.initial
        self.query  = (query ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.transportDelegate = ConnectionTransportDelegate(connection: self)
    }

    public convenience init(url: URL) {
        self.init(url: url, query: "")
    }

    public func start(transport: Transport? = nil) {
        if changeState(from: State.initial, to: State.connecting) == nil {
            failOpenWithError(error: SignalRError.invalidState, changeState: false)
            return;
        }

        startDispatchGroup.enter()

        let httpClient = DefaultHttpClient()

        var negotiateUrlComponents = URLComponents(url: url.appendingPathComponent("negotiate"), resolvingAgainstBaseURL: false)!
        negotiateUrlComponents.percentEncodedQuery = query

        httpClient.get(url:negotiateUrlComponents.url!) {(httpResponse, error) in
            if error != nil {
                print(error.debugDescription)
                self.startDispatchGroup.leave()

                self.failOpenWithError(error: error!, changeState: true)
                return
            }

            if httpResponse!.statusCode == 200 {
                // connection is being stopped even though start has not finished yet
                if (self.state != State.connecting) {
                    self.startDispatchGroup.leave()
                    self.failOpenWithError(error: SignalRError.connectionIsBeingClosed, changeState: false)
                    return
                }

                let contents = String(data: (httpResponse!.contents)!, encoding: String.Encoding.utf8) ?? ""

                if self.query != "" {
                    self.query += "&"
                }

                // TODO: verify if contents is valid id/characters?
                self.query += "id=\(contents)"

                self.transport = transport ?? WebsocketsTransport()
                self.transport!.delegate = self.transportDelegate

                self.transport!.start(url: self.url, query: self.query)
            }
            else {
                self.startDispatchGroup.leave()

                print("HTTP request error. statusCode: \(httpResponse!.statusCode)\ndescription: \(httpResponse!.contents)")
                self.failOpenWithError(error: SignalRError.webError(statusCode: httpResponse!.statusCode), changeState: true)
            }
        }
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

    public func stop() {
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
                t.close()
            }
            else {
                Util.dispatchToMainThread {
                    self.delegate?.connectionDidClose(error: nil)
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
                self.delegate?.connectionDidClose(error: error)
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
    private weak var connection: Connection?

    fileprivate init(connection: Connection!) {
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
