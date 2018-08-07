//
//  WebsocketsTransport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/23/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class WebsocketsTransport: Transport {
    private let transportQueue: DispatchQueue = DispatchQueue(label: "SignalR.webSocketTransport.queue")
    private var isTransportClosed = false
    private let logger: Logger

    var webSocket:WebSocket? = nil
    public weak var delegate: TransportDelegate? = nil

    init(logger: Logger) {
        self.logger = logger
    }

    public func start(url: URL, options: HttpConnectionOptions) {
        var request = URLRequest(url: convertUrl(url: url))
        
        populateHeaders(headers: options.headers, request: &request)
        setAccessToken(accessTokenProvider: options.accessTokenProvider, request: &request)
        
        webSocket = WebSocket(request: request)

        webSocket!.event.open = { [weak self] in
            guard let welf = self else { return }
            
            welf.delegate?.transportDidOpen()
        }

        webSocket!.event.close = { [weak self] code, reason, clean in
            guard let welf = self else { return }
        
            // the transport could have already been closed as a result of an error. In this case we should not call
            // transportDidClose again on the delegate.
            guard !welf.markTransportClosed() else {
                // TODO: add logging
                return
            }

            if clean {
                welf.delegate?.transportDidClose(nil)
            } else {
                welf.delegate?.transportDidClose(WebSocketsTransportError.webSocketClosed(statusCode: code, reason: reason))
            }
        }

        webSocket!.event.error = { [weak self] error in
            guard let welf = self else { return }
        
            // This handler should not be called after the close event but we need to mark the transport as closed to prevent calling transportDidClose
            // on the delegate multiple times so we can as well add the check and log
            guard !welf.markTransportClosed() else {
                // TODO: add logging
                return
            }

            welf.delegate?.transportDidClose(error)
        }

        webSocket!.event.message = { [weak self] message in
            guard let welf = self else { return }
            
            if let text = message as? String {
                welf.delegate?.transportDidReceiveData(text.data(using: .utf8)!)
            } else {
                welf.delegate?.transportDidReceiveData(message as! Data)
            }
        }
        webSocket!.open()
    }

    public func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
        webSocket?.send(data: data)
        sendDidComplete(nil)
    }

    public func close() {
        webSocket?.close()
    }

    private func convertUrl(url: URL) -> URL {
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if (components.scheme == "http") {
                components.scheme = "ws"
            } else if (components.scheme == "https") {
                components.scheme = "wss"
            }
            return components.url!
        }

        return url
    }
    
    @inline(__always) private func populateHeaders(headers: [String : String], request: inout URLRequest) {
        headers.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
    }

    @inline(__always) private func setAccessToken(accessTokenProvider: () -> String?, request: inout URLRequest) {
        if let accessToken = accessTokenProvider() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
    }

    private func markTransportClosed() -> Bool {
        var previousCloseStatus = false

        transportQueue.sync {
            previousCloseStatus = isTransportClosed
            isTransportClosed = true
        }

        return previousCloseStatus
    }
}

fileprivate enum WebSocketsTransportError: Error {
    case webSocketClosed(statusCode: Int, reason: String)
}
