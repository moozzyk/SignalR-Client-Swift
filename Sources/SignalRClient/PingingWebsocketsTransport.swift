//
//  PingingWebSocketsTransport.swift
//  iFNApp
//
//  Created by Michael Danzig on 06.03.20.
//  Copyright © 2020 ABC New Media AG. All rights reserved.
//

import Foundation

/// A copy of the WebsocketTransport with the addition of sending pings in certain intervals.
public class PingingWebsocketsTransport: WebsocketsTransport {
    private var pingTimer: Timer?
    /// The time in secconds after a message has been received or after the connection has been established that needs to pass before a ping is sent.
    public var pingInterval = 90
    /// The time in secconds to wait for a response to a ping.
    public var pingTimeout = 10
    
    func resetPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(pingInterval), target: self, selector: #selector(sendPing), userInfo: nil, repeats: false)
    }
    
    @objc
    func sendPing() {
        pingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(pingTimeout), target: self, selector: #selector(pingTimedOut), userInfo: nil, repeats: false)
        webSocket?.ping()
    }
    
    @objc
    private func pingTimedOut() {
        webSocket?.close()
        let error = WebSocketsTransportError.PingTimedOut
        logger.log(logLevel: .info, message: "WebSocket error. Error: \(error)")
        guard !self.markTransportClosed() else {
            self.logger.log(logLevel: .info, message: "Transport already marked as closed - ignoring error")
            return
        }
        self.delegate?.transportDidClose(error)
    }

    override public func start(url: URL, options: HttpConnectionOptions) {
        logger.log(logLevel: .info, message: "Starting WebSocket transport")
        var request = URLRequest(url: convertUrl(url: url))

        populateHeaders(headers: options.headers, request: &request)
        setAccessToken(accessTokenProvider: options.accessTokenProvider, request: &request)

        webSocket = WebSocket(request: request)

        webSocket!.event.open = { [weak self] in
            guard let welf = self else { return }
            welf.logger.log(logLevel: .info, message: "WebSocket open")

            welf.delegate?.transportDidOpen()
            self?.resetPingTimer()
        }
        
        webSocket!.event.close = { [weak self] (code, reason, clean) in
            guard let welf = self else { return }
            welf.pingTimer?.invalidate()
            
            welf.logger.log(logLevel: .info, message: "WebSocket close. Clean: \(clean), code: \(code), reason: \(reason)")

            // the transport could have already been closed as a result of an error. In this case we should not call
            // transportDidClose again on the delegate.
            guard !welf.markTransportClosed() else {
                welf.logger.log(logLevel: .debug, message: "Transport already marked as closed due to an error - ignoring close")
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
            
            welf.pingTimer?.invalidate()

            welf.logger.log(logLevel: .info, message: "WebSocket error. Error: \(error)")
            // This handler should not be called after the close event but we need to mark the transport as closed to prevent calling transportDidClose
            // on the delegate multiple times so we can as well add the check and log
            guard !welf.markTransportClosed() else {
                welf.logger.log(logLevel: .info, message: "Transport already marked as closed - ignoring error")
                return
            }

            welf.delegate?.transportDidClose(error)
        }

        webSocket!.event.message = { [weak self] message in
            guard let welf = self else { return }
            if let text = message as? String {
                welf.delegate?.transportDidReceiveData(text.data(using: .utf8)!)
            } else if let bytes = message as? [UInt8] {
                welf.delegate?.transportDidReceiveData(Data(bytes))
            } else {
                welf.delegate?.transportDidReceiveData(message as! Data)
            }
            welf.resetPingTimer()
        }
        webSocket!.open()
    }
}

extension PingingWebsocketsTransport: WebSocketDelegate {
    public func webSocketOpen() {
        resetPingTimer()
    }

    public func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        pingTimer?.invalidate()
    }

    public func webSocketError(_ error: NSError) {
        resetPingTimer()
    }
}
