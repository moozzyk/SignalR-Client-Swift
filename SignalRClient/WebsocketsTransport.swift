//
//  WebsocketsTransport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/23/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation
// import SwiftWebSocket

public class WebsocketsTransport: Transport {
    var webSocket:WebSocket? = nil
    public weak var delegate: TransportDelegate! = nil

    public func start(url: URL) {
        webSocket = WebSocket(url: convertUrl(url: url))

        webSocket!.event.open = {
            self.delegate?.transportDidOpen()
        }

        webSocket!.event.close = { code, reason, clean in
            if clean {
                self.delegate?.transportDidClose(nil)
            } else {
                // TODO: Error/reason
                self.delegate?.transportDidClose(nil)
            }
        }

        webSocket!.event.error = { error in
            self.delegate!.transportDidClose(error)
        }

        webSocket!.event.message = { message in
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
}
