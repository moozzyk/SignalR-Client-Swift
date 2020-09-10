//
//  TransportType.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/22/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

public struct TransportType: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let longPolling = TransportType(rawValue: 1 << 0)
    static let serverSentEvents = TransportType(rawValue: 1 << 1) // Not supported
    public static let webSockets = TransportType(rawValue: 1 << 2)
    
    public static let all: TransportType = [ .longPolling, .webSockets ]
}

extension TransportType {
    static func fromString(transportName: String) throws -> TransportType {
        switch transportName {
        case "WebSockets":
            return TransportType.webSockets
        case "ServerSentEvents":
            return TransportType.serverSentEvents
        case "LongPolling":
            return TransportType.longPolling
        default:
            throw SignalRError.invalidOperation(message: "Invalid transport name: '\(transportName)'")
        }
    }
}
