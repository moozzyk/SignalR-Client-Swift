//
//  Connection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class Connection {
    private let connectionQueue: DispatchQueue
    private var transportDelegate: TransportDelegate?

    private var state: State
    private let url: URL
    private var transport: WebsocketsTransport?

    public weak var delegate: ConnectionDelegate!

    private enum State {
        case initial
        case connecting
        case connected
        case stopping
        case stopped
    }

    public init(url: URL) {
        connectionQueue = DispatchQueue(label: "SignalR.queue")
        self.url = url
        self.state = State.initial
    }

    public func start() {

        if !changeState(from: State.initial, to: State.connecting) {
            // TODO: handle
        }

        // TODO: introduce transport protocol and default to Websockets transport instead of hardcoding it
        transportDelegate = ConnectionTransportDelegate(connection: self)
        transport = WebsocketsTransport()
        transport!.delegate = transportDelegate

        let httpClient = DefaultHttpClient()
        let negotiateUrl = url.appendingPathComponent("negotiate")

        httpClient.get(url:negotiateUrl, completionHandler: {(httpResponse, error) in
            if httpResponse?.statusCode == 200 {
                let contents = String(data: (httpResponse!.contents)!, encoding: String.Encoding.utf8) ?? ""
                self.transport!.start(url: self.url, query: "id=\(contents)")
            }
            else {
                _ = self.changeState(from: nil, to: State.stopped)
                // TODO: handle failures
                // let contents = String(data: (httpResponse!.contents)!, encoding: String.Encoding.utf8) ?? ""
                // completionHandler(error ?? WebError(statusCode: httpResponse!.statusCode, description: contents))
            }
        })
    }

    public func send(data: Data) throws {
        // TODO: don't allow to send if the connection is not running
        try transport!.send(data: data)
    }

    public func stop() {
        transport?.close()
    }

    private func changeState(from: State?, to: State!) -> Bool {
        var result = false

        connectionQueue.sync {
            if from == nil || from == state {
                state = to
                result = true
            }
        }

        return result
    }

    fileprivate func transportDidOpen() {
        delegate?.connectionDidOpen(connection: self)
    }

    fileprivate func transportDidReceiveData(_ data: Data) {
        delegate?.connectionDidReceiveData(connection: self, data: data)
    }

    fileprivate func transportDidClose(_ error: Error?) {
        delegate?.connectionDidClose(error: error)
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
