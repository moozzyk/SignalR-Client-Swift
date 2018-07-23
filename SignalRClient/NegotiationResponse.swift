//
//  NegotiationResponse.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/8/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//
import Foundation

internal class TransportDescription {
    let transportType: TransportType
    // TODO: this needs to be converted to enum
    let transferFormats: [String]

    init(transportType: TransportType, transferFormats: [String]) {
        self.transportType = transportType
        self.transferFormats = transferFormats
    }
}

internal class NegotiationResponse {
    let connectionId: String
    let availableTransports: [TransportDescription]

    init(connectionId: String, availableTransports: [TransportDescription]) {
        self.connectionId = connectionId
        self.availableTransports = availableTransports
    }

    static func parse(payload: Data?) throws -> NegotiationResponse {
        guard let payload = payload else {
            throw SignalRError.invalidNegotiationResponse(message: "negotiation payload is nil")
        }

        guard let negotiationResponseJSON = try getNegotiationResponseJSON(payload: payload) else {
            throw SignalRError.invalidNegotiationResponse(message: "negotiation response is not a JSON object")
        }

        let connectionId = try parseConnectionId(negotiationResponseJSON: negotiationResponseJSON)
        let availableTransports = try parseAvailableTransports(negotiationResponseJSON: negotiationResponseJSON)

        return NegotiationResponse(connectionId: connectionId, availableTransports: availableTransports)
    }

    private static func getNegotiationResponseJSON(payload: Data) throws -> [String: Any?]? {
        do {
            return try JSONSerialization.jsonObject(with: payload) as? [String: Any?]
        } catch {
            throw SignalRError.invalidNegotiationResponse(message: "\(error)")
        }
    }

    private static func parseConnectionId(negotiationResponseJSON: [String: Any?]) throws -> String {
        guard let connectionId = negotiationResponseJSON["connectionId"] as? String else {
            throw SignalRError.invalidNegotiationResponse(message: "connectionId property not found or invalid")
        }

        return connectionId
    }

    private static func parseAvailableTransports(negotiationResponseJSON: [String: Any?]) throws -> [TransportDescription] {
        guard let transports = negotiationResponseJSON["availableTransports"] as? [[String: Any?]] else {
            throw SignalRError.invalidNegotiationResponse(message: "availableTransports property not found or invalid")
        }

        return try transports.map { try parseTransport(transportJSON: $0) }
    }

    private static func parseTransport(transportJSON: [String: Any?]) throws -> TransportDescription {
        guard let transportName = transportJSON["transport"] as? String,
            let transportType = try? TransportType.fromString(transportName: transportName) else {
            throw SignalRError.invalidNegotiationResponse(message: "transport property not found or invalid")
        }

        guard let transferFormatsJSON = transportJSON["transferFormats"] as? [String] else {
            throw SignalRError.invalidNegotiationResponse(message: "transferFormats property not found or invalid")
        }

        let transferFormats = try transferFormatsJSON.map { transferFormat -> String in
            switch transferFormat {
            case "Text":
                return "Text"
            case "Binary":
                return "Binary"
            default:
                throw SignalRError.invalidNegotiationResponse(message: "invalid transfer format '\(transferFormat)'")
            }
        }

        if (transferFormats.count == 0) {
            throw SignalRError.invalidNegotiationResponse(message: "empty list of transfer formats")
        }

        return TransportDescription(transportType: transportType, transferFormats: transferFormats)
    }
}
