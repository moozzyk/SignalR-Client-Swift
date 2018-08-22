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
        self.logger.log(logLevel: .info, message: "Starting WebSocket transport")
        var request = URLRequest(url: convertUrl(url: url))
        
        populateHeaders(headers: options.headers, request: &request)
        setAccessToken(accessTokenProvider: options.accessTokenProvider, request: &request)
        
        webSocket = WebSocket(request: request)

        webSocket!.event.open = {
            self.logger.log(logLevel: .info, message: "WebSocket open")
            self.delegate?.transportDidOpen()
        }

        webSocket!.event.close = { code, reason, clean in
            self.logger.log(logLevel: .info, message: "WebSocket close. Clean: \(clean), code: \(code), reason: \(reason)")
            // the transport could have already been closed as a result of an error. In this case we should not call
            // transportDidClose again on the delegate.
            guard !self.markTransportClosed() else {
                self.logger.log(logLevel: .debug, message: "Transport already marked as closed due to an error - ignoring close")
                return
            }

            if clean {
                self.delegate?.transportDidClose(nil)
            } else {
                self.delegate?.transportDidClose(WebSocketsTransportError.webSocketClosed(statusCode: code, reason: reason))
            }
        }

        webSocket!.event.error = { error in
            self.logger.log(logLevel: .info, message: "WebSocket error. Error: \(error)")
            // This handler should not be called after the close event but we need to mark the transport as closed to prevent calling transportDidClose
            // on the delegate multiple times so we can as well add the check and log
            guard !self.markTransportClosed() else {
                self.logger.log(logLevel: .info, message: "Transport already marked as closed - ignoring error")
                return
            }

            self.delegate?.transportDidClose(error)
        }

        webSocket!.event.message = { message in
            self.logger.log(logLevel: .debug, message: "WebSocket message")

            if let text = message as? String {
                self.delegate?.transportDidReceiveData(text.data(using: .utf8)!)
            } else {
                self.delegate?.transportDidReceiveData(message as! Data)
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
