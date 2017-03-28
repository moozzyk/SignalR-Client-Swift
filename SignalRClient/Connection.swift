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

    private var state: State
    private let url: URL
    private var query: String
    private var transport: Transport?

    public weak var delegate: SocketConnectionDelegate!

    private enum State {
        case initial
        case connecting
        case connected
        case stopping
        case stopped
    }

    init(url: URL, query: String?) {
        connectionQueue = DispatchQueue(label: "SignalR.connection.queue")
        self.url = url
        self.state = State.initial
        self.query  = (query ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }

    convenience init(url: URL) {
        self.init(url: url, query: "")
    }

    public func start(transport: Transport? = nil) {

        if !changeState(from: State.initial, to: State.connecting) {
            failOpenWithError(error: SignalRError.invalidState)
            return;
        }

        self.transport = transport ?? WebsocketsTransport()
        self.transport!.delegate = self

        let httpClient = DefaultHttpClient()

        var negotiateUrlComponents = URLComponents(url: url.appendingPathComponent("negotiate"), resolvingAgainstBaseURL: false)!
        negotiateUrlComponents.percentEncodedQuery = query

        httpClient.get(url:negotiateUrlComponents.url!, completionHandler: {(httpResponse, error) in
            if error != nil {
                print(error.debugDescription)
                self.failOpenWithError(error: error!)
                return
            }

            if httpResponse!.statusCode == 200 {
                let contents = String(data: (httpResponse!.contents)!, encoding: String.Encoding.utf8) ?? ""

                if self.query != "" {
                    self.query += "&"
                }
                self.query += "id=\(contents)"

                self.transport!.start(url: self.url, query: self.query)
            }
            else {
                print("HTTP request error. statusCode: \(httpResponse!.statusCode)\ndescription: \(httpResponse!.contents)")
                self.failOpenWithError(error: SignalRError.webError(statusCode: httpResponse!.statusCode))
            }
        })
    }

    private func failOpenWithError(error: Error) {
        _ = self.changeState(from: nil, to: State.stopped)
        delegate?.connectionDidFailToOpen(error: error)
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
}

extension Connection: TransportDelegate {
    public func transportDidOpen() {
        delegate?.connectionDidOpen(connection: self)
    }

    public func transportDidReceiveData(_ data: Data) {
        delegate?.connectionDidReceiveData(connection: self, data: data)
    }

    public func transportDidClose(_ error: Error?) {
        delegate?.connectionDidClose(error: error)
    }
}
