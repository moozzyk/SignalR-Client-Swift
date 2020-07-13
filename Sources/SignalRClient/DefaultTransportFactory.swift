//
//  DefaultTransportFactory.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 8/22/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

internal class DefaultTransportFactory: TransportFactory {
    let logger: Logger
    let permittedTransportTypes: TransportType

    init(logger: Logger, permittedTransportTypes: TransportType = .all) {
        self.logger = logger
        self.permittedTransportTypes = permittedTransportTypes
    }

    func createTransport(availableTransports: [TransportDescription]) throws -> Transport {
        for transport in availableTransports {
            if transport.transportType == .webSockets, permittedTransportTypes.contains(.webSockets) {
                return WebsocketsTransport(logger: logger)
            } else if transport.transportType == .longPolling, permittedTransportTypes.contains(.longPolling) {
                return LongPollingTransport(logger: logger)
            }
        }

        throw SignalRError.noSupportedTransportAvailable
    }
}
