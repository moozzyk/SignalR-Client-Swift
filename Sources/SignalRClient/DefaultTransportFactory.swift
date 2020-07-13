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
    var orderOfPreference: [TransportType] = [.webSockets, .longPolling]
        
    init(logger: Logger, permittedTransportTypes: TransportType = .all) {
        self.logger = logger
        self.permittedTransportTypes = permittedTransportTypes
    }
    
    func createTransport(availableTransports: [TransportDescription]) throws -> Transport {
        let choices = determineAvailableTypes(availableTransports: availableTransports)
        let chosenType = chooseType(choices: choices, orderOfPreference: orderOfPreference)
        recordChoice(chosenType)
        guard let transport = buildTransport(type: chosenType) else {
            throw SignalRError.noSupportedTransportAvailable
        }
        return transport
    }
    
    /// Builds the set of available transport types from the list of TransportDescriptions
    private func determineAvailableTypes(availableTransports: [TransportDescription]) -> TransportType {
        var choices: TransportType = .init()
        for transport in availableTransports {
            choices.formUnion(transport.transportType)
        }
        choices.formIntersection(permittedTransportTypes)
        return choices
    }
    
    /// Chooses a transport type from the supplied set of choices according to the supplied order of preference
    private func chooseType(choices: TransportType, orderOfPreference: [TransportType]) -> TransportType? {
        var chosen: TransportType? = nil
        for type in orderOfPreference {
            if choices.contains(type) {
                chosen = type
                break
            }
        }
        return chosen
    }
    
    /// Sets the chosen type to have lowest priority for future reconnect attempts, to allow fallback when a transport does not work properly, e.g. due to network conditions.
    private func recordChoice(_ choice: TransportType?) {
        if let choice = choice {
            orderOfPreference.removeAll(where: { $0 == choice })
            orderOfPreference.append(choice)
        }
    }
    
    /// Creates a Transport instance for the given (singular) transport type
    private func buildTransport(type: TransportType?) -> Transport? {
        if type == .webSockets {
            logger.log(logLevel: .info, message: "Selected WebSockets transport")
            return WebsocketsTransport(logger: logger)
        } else if type == .longPolling {
            logger.log(logLevel: .info, message: "Selected LongPolling transport")
            return LongPollingTransport(logger: logger)
        } else {
            return nil
        }
    }
}
