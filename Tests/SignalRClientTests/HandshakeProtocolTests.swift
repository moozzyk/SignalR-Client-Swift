//
//  HandshakeProtocolTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 4/14/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class HandshakeProtocolTests: XCTestCase {
    
    public func testThatHandshakeProtocolWritesCorrectHandshakeMessage() {
        let handshakeMessage = HandshakeProtocol.createHandshakeRequest(hubProtocol: HubProtocolFake())
        XCTAssertEqual("{\"protocol\": \"fakeProtocol\", \"version\": 42}\u{1e}", handshakeMessage)
    }

    public func testThatHandshakeProtocolReturnsNilForEmptyHandshakeResponse() {
        XCTAssertNil(HandshakeProtocol.parseHandshakeResponse(data: "{}\u{1e}".data(using: .utf8)!).0)
        XCTAssertNil(HandshakeProtocol.parseHandshakeResponse(data: "{ }\u{1e}".data(using: .utf8)!).0)
    }

    public func testThatHandshakeProtocolReturnsErroHandshakeResponse() {
        let (error, _) = HandshakeProtocol.parseHandshakeResponse(data: "{ \"error\": \"handshake failed\"}\u{1e}".data(using: .utf8)!)
        switch (error as? SignalRError) {
        case .handshakeError(let errorMessage)?:
            XCTAssertEqual("handshake failed", errorMessage)
            break
        default:
            XCTFail()
            break
        }
    }

    public func testThatHandshakeProtocolReturnsErroForUnexpectedResponse() {
        let testResponses = ["{ \"message\": \"hello\"}\u{1e}", "{ \"message\": \"hello\", \"answer\": 42 }\u{1e}", "[]\u{1e}"]

        testResponses.forEach {
            let (error, _) = HandshakeProtocol.parseHandshakeResponse(data: $0.data(using: .utf8)!)
            switch (error as? SignalRError) {
            case .handshakeError(let errorMessage)?:
                XCTAssertEqual("Invalid handshake response.", errorMessage)
                break
            default:
                XCTFail()
                break
            }
        }
    }

    public func testThatHandshakeProtocolReturnsErroForInvalidJson() {
        let error = HandshakeProtocol.parseHandshakeResponse(data: "{\u{1e}".data(using: .utf8)!)
        XCTAssertNotNil(error)
    }

    public func testThatHandshakeProtocolReturnsErroForPartialHandshakePayload() {
        let testResponses = ["", "{"]

        testResponses.forEach {
            let data = $0.data(using: .utf8)!
            let (error, remainingData) = HandshakeProtocol.parseHandshakeResponse(data: data)
            switch (error as? SignalRError) {
            case .handshakeError(let errorMessage)?:
                XCTAssertEqual("Received partial handshake response.", errorMessage)
                XCTAssertTrue(remainingData.elementsEqual(data))
                break
            default:
                XCTFail()
                break
            }
        }
    }

    public func testThatHandshakeProtocolReturnsRemainingDataAfterParsing() {
        let testResponses = ["{}\u{1e}abc", "{\"error\": \"error occurred\"}\u{1e}123"]

        testResponses.forEach {
            let data = $0.data(using: .utf8)!
            let (_, remainingData) = HandshakeProtocol.parseHandshakeResponse(data: data)
            XCTAssertTrue(remainingData.elementsEqual(data[(data.endIndex - 3)...]))
        }
    }
}
