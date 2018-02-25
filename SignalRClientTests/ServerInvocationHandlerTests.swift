//
//  ServerInvocationHandlerTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 2/25/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class InvocationHandlerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatInvocationHandlerPassesErrorForErrorCompletionMessage() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), invocationDidComplete: { result, error in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            switch (error as! SignalRError) {
            case .hubInvocationError(let errorMessage):
                XCTAssertEqual("Error occurred!", errorMessage)
                break
            default:
                XCTFail()
                break
            }
        })

        let completionMessage = CompletionMessage(invocationId: "", error: "Error occurred!")
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesNilAsResultForVoidCompletionMessage() {
        let invocationHandler = InvocationHandler<Any>(typeConverter: JSONTypeConverter(), invocationDidComplete: { result, error in
            XCTAssertNil(error)
            XCTAssertNil(result)
        })

        let completionMessage = CompletionMessage(invocationId: "")
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesValueForResultCompletionMessage() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), invocationDidComplete: { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(42, result)
        })

        let completionMessage = CompletionMessage(invocationId: "", result: 42)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesErrorIfResultConversionFails() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), invocationDidComplete: { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.unsupportedType))
        })

        let completionMessage = CompletionMessage(invocationId: "", result: "42")
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatRaiseErrorPassesError() {
        let invocationHandler = InvocationHandler<Any>(typeConverter: JSONTypeConverter(), invocationDidComplete: { result, error in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
        })

        invocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
    }
}

class StreamInvocationHandlerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatInvocationHandlerPassesErrorForErrorCompletionMessage() {
        let streamInvocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNotNil(error)
            switch (error as! SignalRError) {
            case .hubInvocationError(let errorMessage):
                XCTAssertEqual("Error occurred!", errorMessage)
                break
            default:
                XCTFail()
                break
            }
        })

        let completionMessage = CompletionMessage(invocationId: "", error: "Error occurred!")
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesNilAsResultForVoidCompletionMessage() {
        let streamInvocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNil(error)
        })

        let completionMessage = CompletionMessage(invocationId: "")
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatRaiseErrorPassesError() {
        let streamInvocationHandler = StreamInvocationHandler<Any>(typeConverter: JSONTypeConverter(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
        })

        streamInvocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
    }
}
