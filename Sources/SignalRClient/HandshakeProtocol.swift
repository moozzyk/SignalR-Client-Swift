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

    static func parseHandshakeResponse(data: Data) -> (Error?, Data) {
        if let idx = data.firstIndex(where: {$0 == 0x1e}) {
            let error = parseHandshakeResponse(handshakeResponse: data[0..<idx])
            return (error, data.dropFirst(Int(idx + 1)))
        }

        return (SignalRError.handshakeError(message: "Received partial handshake response."), data)
    }

    private static func parseHandshakeResponse(handshakeResponse: Data) -> Error? {
        do {
            if let handshakeResponseJson = try JSONSerialization.jsonObject(with: handshakeResponse) as? [String: Any] {
                if handshakeResponseJson.count == 0 {
                    return nil
                }

                if handshakeResponseJson.count == 1, let errorMessage = handshakeResponseJson["error"] as? String {
                    return SignalRError.handshakeError(message: errorMessage)
                }
            }
        } catch {
            return error
        }

        return SignalRError.handshakeError(message: "Invalid handshake response.")
    }
}
