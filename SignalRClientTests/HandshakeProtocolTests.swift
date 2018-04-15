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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public func testThatHandshakeProtocolWritesCorrectHandshakeMessage() {
        let handshakeMessage = HandshakeProtocol.createHandshakeRequest(hubProtocol: HubProtocolFake())
        XCTAssertEqual("{\"protocol\": \"fakeProtocol\", \"version\": 42}\u{1e}", handshakeMessage)
    }

    public func testThatHandshakeProtocolReturnsNilForEmptyHandshakeResponse() {
        XCTAssertNil(HandshakeProtocol.parseHandshakeResponse(handshakeResponse: "{}"))
        XCTAssertNil(HandshakeProtocol.parseHandshakeResponse(handshakeResponse: "{ }"))
    }

    public func testThatHandshakeProtocolReturnsErroForErrorHandshakeResponse() {
        let error = HandshakeProtocol.parseHandshakeResponse(handshakeResponse: "{ \"error\": \"handshake failed\"}")
        switch (error as? SignalRError) {
        case .handshakeError(let errorMessage)?:
            XCTAssertEqual("handshake failed", errorMessage)
            break
        default:
            XCTFail()
            break
        }
    }

    public func testThatHandshakeProtocolReturnsErroForErrorForUnexpectedResponse() {
        let testResponses = ["{ \"message\": \"hello\"}", "{ \"message\": \"hello\", \"answer\": 42 }", "[]"]

        testResponses.forEach {
            let error = HandshakeProtocol.parseHandshakeResponse(handshakeResponse: $0)
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
        let error = HandshakeProtocol.parseHandshakeResponse(handshakeResponse: "{")
        XCTAssertNotNil(error)
    }

    class HubProtocolFake: HubProtocol {
        let name = "fakeProtocol"
        let version = 42
        let type = ProtocolType.Binary
        let typeConverter: TypeConverter = JSONTypeConverter()

        func parseMessages(input: Data) throws -> [HubMessage] {
            throw NSError(domain: "Not supported", code: -1)
        }

        func writeMessage(message: HubMessage) throws -> Data {
            throw NSError(domain: "Not supported", code: -1)
        }
    }
}
