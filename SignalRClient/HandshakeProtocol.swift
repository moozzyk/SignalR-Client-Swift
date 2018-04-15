//
//  HandshakeProtocol.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 4/14/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

class HandshakeProtocol {
    static func createHandshakeRequest(hubProtocol: HubProtocol) -> String {
        return "{\"protocol\": \"\(hubProtocol.name)\", \"version\": \(hubProtocol.version)}\u{1e}"
    }

    static func parseHandshakeResponse(handshakeResponse: String) -> Error? {
        // fast path
        if (handshakeResponse == "{}") {
            return nil
        }

        do {
            if let handshakeResponseJson = try JSONSerialization.jsonObject(with: handshakeResponse.data(using: .utf8)!) as? NSDictionary {
                if handshakeResponseJson.count == 0 {
                    return nil
                }

                if handshakeResponseJson.count == 1, let errorMessage = handshakeResponseJson.value(forKey: "error") as? String {
                    return SignalRError.handshakeError(message: errorMessage)
                }
            }
        } catch {
            return error
        }

        return SignalRError.handshakeError(message: "Invalid handshake response.")
    }
}
