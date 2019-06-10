//
//  HubProtocolFake.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 4/15/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

@testable import SignalRClient

public class HubProtocolFake: HubProtocol {
    public let name = "fakeProtocol"
    public let version = 42
    public let type = ProtocolType.Binary

    public func parseMessages(input: Data) throws -> [HubMessage] {
        throw NSError(domain: "Not supported", code: -1)
    }

    public func writeMessage(message: HubMessage) throws -> Data {
        throw NSError(domain: "Not supported", code: -1)
    }
}
