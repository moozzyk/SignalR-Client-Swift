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
    let transferFormats: [TransferFormat]

    init(transportType: TransportType, transferFormats: [TransferFormat]) {
        self.transportType = transportType
        self.transferFormats = transferFormats
    }
}

internal protocol NegotiationPayload {
}

internal class NegotiationResponse: NegotiationPayload {
    let connectionId: String
    let connectionToken: String?
    let version: Int
    let availableTransports: [TransportDescription]

    init(connectionId: String, connectionToken: String?, version: Int, availableTransports: [TransportDescription]) {
        self.connectionId = connectionId
        self.connectionToken = connectionToken
        self.version = version
        self.availableTransports = availableTransports
    }
}

internal class Redirection: NegotiationPayload {
    let url: URL
    let accessToken: String

    init(url: URL, accessToken: String) {
        self.url = url
        self.accessToken = accessToken
    }
}

internal class NegotiationPayloadParser {
    static func parse(payload: Data?) throws -> NegotiationPayload {
        guard let payload = payload else {
            throw SignalRError.invalidNegotiationResponse(message: "negotiation payload is nil")
        }

        guard let negotiationResponseJSON = try getNegotiationResponseJSON(payload: payload) else {
            throw SignalRError.invalidNegotiationResponse(message: "negotiation response is not a JSON object")
        }

        if negotiationResponseJSON["url"] == nil {
            return try parseNegotiation(negotiationResponseJSON)
        } else {
            return try parseRedirection(negotiationResponseJSON)
        }
    }

    private static func getNegotiationResponseJSON(payload: Data) throws -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: payload) as? [String: Any]
        } catch {
            throw SignalRError.invalidNegotiationResponse(message: "\(error)")
        }
    }

    private static func parseNegotiation(_ negotiationResponseJSON: [String: Any]) throws -> NegotiationResponse {
        let version = try parseIntNumberProperty(negotiationResponseJSON: negotiationResponseJSON, propertyName: "negotiateVersion") ?? 0
        let connectionId = try parseStringProperty(negotiationResponseJSON: negotiationResponseJSON, propertyName: "connectionId")
        var connectionToken: String? = nil
        if version > 0 {
            connectionToken = try parseStringProperty(negotiationResponseJSON: negotiationResponseJSON, propertyName: "connectionToken")
        }

        let availableTransports = try parseAvailableTransports(negotiationResponseJSON: negotiationResponseJSON)

        return NegotiationResponse(connectionId: connectionId, connectionToken: connectionToken, version: version, availableTransports: availableTransports)
    }

    private static func parseStringProperty(negotiationResponseJSON: [String: Any], propertyName: String) throws -> String {
        guard let propertyValue = negotiationResponseJSON[propertyName] as? String else {
            throw SignalRError.invalidNegotiationResponse(message: "\(propertyName) property not found or invalid")
        }

        return propertyValue
    }

    private static func parseIntNumberProperty(negotiationResponseJSON: [String: Any], propertyName: String) throws -> Int? {
        guard let propertyValue = negotiationResponseJSON[propertyName] as? Int? else {
            throw SignalRError.invalidNegotiationResponse(message: "\(propertyName) property not found or invalid")
        }

        return propertyValue
    }

    private static func parseAvailableTransports(negotiationResponseJSON: [String: Any]) throws -> [TransportDescription] {
        guard let transports = negotiationResponseJSON["availableTransports"] as? [[String: Any]] else {
            throw SignalRError.invalidNegotiationResponse(message: "availableTransports property not found or invalid")
        }

        return try transports.map { try parseTransport(transportJSON: $0) }
    }

    private static func parseTransport(transportJSON: [String: Any]) throws -> TransportDescription {
        guard let transportName = transportJSON["transport"] as? String,
            let transportType = try? TransportType.fromString(transportName: transportName) else {
            throw SignalRError.invalidNegotiationResponse(message: "transport property not found or invalid")
        }

        guard let transferFormatsJSON = transportJSON["transferFormats"] as? [String] else {
            throw SignalRError.invalidNegotiationResponse(message: "transferFormats property not found or invalid")
        }

        let transferFormats = try transferFormatsJSON.map { (transferFormatName) -> TransferFormat in
            guard let transferFormat = TransferFormat.init(rawValue: transferFormatName) else {
                throw SignalRError.invalidNegotiationResponse(message: "invalid transfer format '\(transferFormatName)'")
            }
            return transferFormat
        }

        if (transferFormats.count == 0) {
            throw SignalRError.invalidNegotiationResponse(message: "empty list of transfer formats")
        }

        return TransportDescription(transportType: transportType, transferFormats: transferFormats)
    }

    private static func parseRedirection(_ negotiationResponseJSON: [String: Any]) throws -> Redirection {
        let urlString = try parseString(negotiationResponseJSON: negotiationResponseJSON, key: "url")
        guard let url = URL(string: urlString) else {
            throw SignalRError.invalidNegotiationResponse(message: "invalid url '\(urlString)'")
        }
        let accessToken = try parseString(negotiationResponseJSON: negotiationResponseJSON, key: "accessToken")

        return Redirection(url: url, accessToken: accessToken)
    }

    private static func parseString(negotiationResponseJSON: [String: Any], key: String) throws -> String {
        guard let connectionId = negotiationResponseJSON[key] as? String else {
            throw SignalRError.invalidNegotiationResponse(message: "\(key) property not found or invalid")
        }
        return connectionId
    }
}
