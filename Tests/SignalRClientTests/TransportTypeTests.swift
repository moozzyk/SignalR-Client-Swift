//
//  TransportTypeTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 7/22/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class TransportTypeTests: XCTestCase {

    func testFlagValues() {
        XCTAssertEqual(0b0001, TransportType.longPolling.rawValue)
        XCTAssertEqual(0b0010, TransportType.serverSentEvents.rawValue)
        XCTAssertEqual(0b0100, TransportType.webSockets.rawValue)
    }

    func testThatCanCreateTransportTypeFromValidTransportName() {
        XCTAssertEqual(TransportType.longPolling, try! TransportType.fromString(transportName: "LongPolling"))
        XCTAssertEqual(TransportType.serverSentEvents, try! TransportType.fromString(transportName: "ServerSentEvents"))
        XCTAssertEqual(TransportType.webSockets, try! TransportType.fromString(transportName: "WebSockets"))
    }

    func testThatCannotCreateTransportTypeFromInvalidTransportName() {
        ["", "fakeTransport"].forEach { (transportName) in
            do {
                _ = try TransportType.fromString(transportName: transportName)
            } catch {
                let expectedMessage = "Invalid transport name: '\(transportName)'"
                XCTAssertEqual("\(SignalRError.invalidOperation(message: expectedMessage))" , "\(error)")
            }
        }
    }
}
