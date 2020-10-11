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
            TransportDescription(transportType: .webSockets, transferFormats: [.text, .binary]),
            TransportDescription(transportType: .longPolling, transferFormats: [.binary])]
        let negotiationResponse = NegotiationResponse(connectionId: "connectionId", connectionToken: "connectionToken", version: 42, availableTransports: availableTransports)

        XCTAssertEqual("connectionId", negotiationResponse.connectionId)
        XCTAssertEqual("connectionToken", negotiationResponse.connectionToken)
        XCTAssertEqual(42, negotiationResponse.version)
        XCTAssertTrue(availableTransports.elementsEqual(negotiationResponse.availableTransports) { $0 === $1 })
    }

    public func testThatParseCanParseCreatesNegotiationResponseFromValidPayload() {
        let payload = "{\"connectionId\":\"6baUtSEmluCoKvmUIqLUJw\",\"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\",\"negotiateVersion\":1,\"availableTransports\":[{\"transport\":\"WebSockets\",\"transferFormats\":[\"Text\",\"Binary\"]},{\"transport\":\"ServerSentEvents\",\"transferFormats\":[\"Text\"]},{\"transport\":\"LongPolling\",\"transferFormats\":[\"Text\",\"Binary\"]}]}"

        let negotiationResponse = try! NegotiationPayloadParser.parse(payload: payload.data(using: .utf8)) as! NegotiationResponse

        XCTAssertEqual("6baUtSEmluCoKvmUIqLUJw", negotiationResponse.connectionId)
        XCTAssertEqual(3, negotiationResponse.availableTransports.count)
        XCTAssertEqual(.webSockets, negotiationResponse.availableTransports[0].transportType)
        XCTAssertEqual([.text, .binary], negotiationResponse.availableTransports[0].transferFormats)

        XCTAssertEqual(.serverSentEvents, negotiationResponse.availableTransports[1].transportType)
        XCTAssertEqual([.text], negotiationResponse.availableTransports[1].transferFormats)

        XCTAssertEqual(.longPolling, negotiationResponse.availableTransports[2].transportType)
        XCTAssertEqual([.text, .binary], negotiationResponse.availableTransports[2].transferFormats)
    }

    public func testThatCanCreateRedirection() {
        let redirection = Redirection(url: URL(string: "http://fakeuri.org")!, accessToken: "abc")

        XCTAssertEqual(URL(string: "http://fakeuri.org")!, redirection.url)
        XCTAssertEqual("abc", redirection.accessToken)
    }

    public func testThatParseParseCreatesRedirectionResponseFromValidPayload() {
        let payload = "{\"url\":\"http://fakeuri.org\", \"accessToken\": \"abc\"}"

        let redirection = try! NegotiationPayloadParser.parse(payload: payload.data(using: .utf8)) as! Redirection

        XCTAssertEqual(URL(string: "http://fakeuri.org")!, redirection.url)
        XCTAssertEqual("abc", redirection.accessToken)
    }

    public func testThatParseThrowsForInvalidPayloads() {
        let testCases = [
            "1": "Error Domain=NSCocoaErrorDomain Code=3840 \"JSON text did not start with array or object and option to allow fragments not set.\" UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set.}",
            "[1]": "negotiation response is not a JSON object",
            "{}" : "connectionId property not found or invalid",
            "{\"connectionId\": []}" : "connectionId property not found or invalid",
            "{\"connectionId\": \"123\", \"negotiateVersion\": 1 }" : "connectionToken property not found or invalid",
            "{\"connectionId\": \"123\", \"connectionToken\": 1, \"negotiateVersion\": 1}" : "connectionToken property not found or invalid",
            "{\"connectionId\": \"123\", \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": \"1\" }" : "negotiateVersion property not found or invalid",
            "{\"connectionId\": \"123\", \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1}" : "availableTransports property not found or invalid",
            "{\"connectionId\": \"123\", \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1,\"availableTransports\": false}" : "availableTransports property not found or invalid",
            "{\"connectionId\": \"123\", \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1, \"availableTransports\": [{}]}" : "transport property not found or invalid",
            "{\"connectionId\": \"123\", \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1,  \"availableTransports\": [{\"transport\": 42}]}" : "transport property not found or invalid",
            "{\"connectionId\": \"123\",  \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1, \"availableTransports\": [{\"transport\": \"WebSockets\"}]}" : "transferFormats property not found or invalid",
            "{\"connectionId\": \"123\",  \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1, \"availableTransports\": [{\"transport\": \"WebSockets\", \"transferFormats\":{}}]}" : "transferFormats property not found or invalid",
            "{\"connectionId\": \"123\",  \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1, \"availableTransports\": [{\"transport\": \"WebSockets\", \"transferFormats\":[]}]}" : "empty list of transfer formats",
            "{\"connectionId\": \"123\",  \"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\", \"negotiateVersion\": 1, \"availableTransports\": [{\"transport\": \"WebSockets\", \"transferFormats\":[\"Text\", \"abc\"]}]}" : "invalid transfer format 'abc'",
            "{\"url\": 123}" : "url property not found or invalid",
            "{\"url\": \"123\"}" : "accessToken property not found or invalid",
            "{\"accessToken\": \"123\", \"url\": null}" : "url property not found or invalid",
            "{\"accessToken\": 123, \"url\": \"123\"}" : "accessToken property not found or invalid",
        ]

        testCases.forEach {
            let (payload, errorMessage) = $0

            do {
                _ = try NegotiationPayloadParser.parse(payload: payload.data(using: .utf8))
                XCTAssert(false, "exception expected but none thrown")
            } catch {
                XCTAssertEqual("\(error)", "\(SignalRError.invalidNegotiationResponse(message: errorMessage))")
            }
        }
    }
}
