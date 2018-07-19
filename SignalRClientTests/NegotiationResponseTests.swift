//
//  NegotiationResponseTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 7/17/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class NegotiationResponseTests: XCTestCase {
    public func testThatCanCreateNegotiationResponse() {
        let availableTransports = [
            TransportDescription(transport: "t1", transferFormats: ["Text", "Binary"]),
            TransportDescription(transport: "t2", transferFormats: ["Binary"])]
        let negotiationResponse = NegotiationResponse(connectionId: "connectionId", availableTransports: availableTransports)

        XCTAssertEqual("connectionId", negotiationResponse.connectionId)
        XCTAssertTrue(availableTransports.elementsEqual(negotiationResponse.availableTransports) { $0 === $1 })
    }

    public func testThatParseCanParseCreatesNegotiationResponseFromValidPayload() {
        let payload = "{\"connectionId\":\"6baUtSEmluCoKvmUIqLUJw\",\"availableTransports\":[{\"transport\":\"WebSockets\",\"transferFormats\":[\"Text\",\"Binary\"]},{\"transport\":\"ServerSentEvents\",\"transferFormats\":[\"Text\"]},{\"transport\":\"LongPolling\",\"transferFormats\":[\"Text\",\"Binary\"]}]}"

        let negotiationResponse = try! NegotiationResponse.parse(payload: payload.data(using: .utf8))

        XCTAssertEqual("6baUtSEmluCoKvmUIqLUJw", negotiationResponse.connectionId)
        XCTAssertEqual(3, negotiationResponse.availableTransports.count)
        XCTAssertEqual("WebSockets", negotiationResponse.availableTransports[0].transport)
        XCTAssertEqual(["Text", "Binary"], negotiationResponse.availableTransports[0].transferFormats)

        XCTAssertEqual("ServerSentEvents", negotiationResponse.availableTransports[1].transport)
        XCTAssertEqual(["Text"], negotiationResponse.availableTransports[1].transferFormats)

        XCTAssertEqual("LongPolling", negotiationResponse.availableTransports[2].transport)
        XCTAssertEqual(["Text", "Binary"], negotiationResponse.availableTransports[2].transferFormats)
    }

    public func testThatParseThrowsForInvalidPayloads() {
        let testCases = [
            "1": "Error Domain=NSCocoaErrorDomain Code=3840 \"JSON text did not start with array or object and option to allow fragments not set.\" UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set.}",
            "[1]": "negotiation response is not a JSON object",
            "{}" : "connectionId property not found or invalid",
            "{\"connectionId\": []}" : "connectionId property not found or invalid",
            "{\"connectionId\": \"123\"}" : "availableTransports property not found or invalid",
            "{\"connectionId\": \"123\", \"availableTransports\": false}" : "availableTransports property not found or invalid",
            "{\"connectionId\": \"123\", \"availableTransports\": [{}]}" : "transport property not found or invalid",
            "{\"connectionId\": \"123\", \"availableTransports\": [{\"transport\": 42}]}" : "transport property not found or invalid",
            "{\"connectionId\": \"123\", \"availableTransports\": [{\"transport\": \"WebSockets\"}]}" : "transferFormats property not found or invalid",
            "{\"connectionId\": \"123\", \"availableTransports\": [{\"transport\": \"WebSockets\", \"transferFormats\":{}}]}" : "transferFormats property not found or invalid",
            "{\"connectionId\": \"123\", \"availableTransports\": [{\"transport\": \"WebSockets\", \"transferFormats\":[]}]}" : "empty list of transfer formats",
            "{\"connectionId\": \"123\", \"availableTransports\": [{\"transport\": \"WebSockets\", \"transferFormats\":[\"Text\", \"abc\"]}]}" : "invalid transfer format 'abc'",
        ]

        testCases.forEach {
            let (payload, errorMessage) = $0

            do {
                _ = try NegotiationResponse.parse(payload: payload.data(using: .utf8))
                XCTAssert(false, "exception expected but none thrown")
            } catch {
                XCTAssertEqual("\(error)", "\(SignalRError.invalidNegotiationResponse(message: errorMessage))")
            }
        }
    }
}
