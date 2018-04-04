//
//  WebsocketsTransport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/23/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation
import SocketRocket

public class WebsocketsTransport: NSObject, Transport, SRWebSocketDelegate {
    
    var webSocket: SRWebSocket? = nil
    public weak var delegate: TransportDelegate! = nil

    public func start(url:URL) {
        self.webSocket = SRWebSocket(url: url)
        self.webSocket!.delegate = self
        self.webSocket!.open();
    }
    
    public func start(url: URL, headers: [HTTPHeader]) {
        var urlRequest = URLRequest(url: url)
        headers.forEach{ urlRequest.setValue($0.value, forHTTPHeaderField: $0.header) }

        self.webSocket = SRWebSocket(urlRequest: urlRequest)
        self.webSocket!.delegate = self
        self.webSocket!.open();
    }

    public func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
        do {
            try webSocket?.send(data: data)
            sendDidComplete(nil)
        } catch {
            sendDidComplete(error)
        }
    }

    public func close() {
        webSocket?.close()
    }

    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        delegate?.transportDidOpen()
    }

    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith data: Data) {
        delegate?.transportDidReceiveData(data)
    }

    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        delegate?.transportDidReceiveData(string.data(using: .utf8)!)
    }

    public func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        // TODO: Handle error codes
        delegate?.transportDidClose(nil)
    }

    public func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        delegate?.transportDidClose(error)
    }  
}
