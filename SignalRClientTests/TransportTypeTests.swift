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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFlagValues() {
        XCTAssertEqual(0b0001, TransportType.longPolling.rawValue)
        XCTAssertEqual(0b0010, TransportType.serverSentEvents.rawValue)
        XCTAssertEqual(0b0100, TransportType.webSockets.rawValue)
    }

    func testThatCanCreateTransportFromValidTransportNames() {
        XCTAssertEqual(TransportType.longPolling, try! TransportType.fromString(transportName: "LongPolling"))
        XCTAssertEqual(TransportType.serverSentEvents, try! TransportType.fromString(transportName: "ServerSentEvents"))
        XCTAssertEqual(TransportType.webSockets, try! TransportType.fromString(transportName: "WebSockets"))
    }

    func testThatCannotCreateFromInvalidTransportNames() {
        ["", "fakeTransport"].forEach { (transportName) in
            do {
                _ = try TransportType.fromString(transportName: transportName)
            } catch {
                let expectedMessage = "Invalid transport name: '\(transportName)'"
                XCTAssertEqual("\(SignalRError.invalidOperation(message: expectedMessage))" , "\(error)")
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
