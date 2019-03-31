//
//  ServerInvocationHandlerTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 2/25/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SwiftSignalRClient

class InvocationHandlerTests: XCTestCase {

    func testThatInvocationHandlerCreatesInvocationMessage() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in })
        let invocationMessage = invocationHandler.createInvocationMessage(invocationId: "42", method: "testMethod", arguments:[1, "abc"]) as? InvocationMessage
        XCTAssertNotNil(invocationMessage)
        XCTAssertEqual(MessageType.Invocation, invocationMessage!.messageType)
        XCTAssertEqual("42", invocationMessage!.invocationId)
        XCTAssertEqual("testMethod", invocationMessage!.target)
        XCTAssertEqual(2, invocationMessage!.arguments.count)
        XCTAssertEqual(1, invocationMessage!.arguments[0] as? Int)
        XCTAssertEqual("abc", invocationMessage!.arguments[1] as? String)
    }

    func testThatInvocationHandlerReturnsErrorForStreamItem() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in })
        if let error = invocationHandler.processStreamItem(streamItemMessage: StreamItemMessage(invocationId: "42", item: nil)) as? SignalRError {
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.protocolViolation))
        } else {
            XCTFail()
        }
   }

    func testThatInvocationHandlerPassesErrorForErrorCompletionMessage() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in
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
        let invocationHandler = InvocationHandler<Any>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(error)
            XCTAssertNil(result)
        })

        let completionMessage = CompletionMessage(invocationId: "")
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesValueForResultCompletionMessage() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(42, result)
        })

        let completionMessage = CompletionMessage(invocationId: "", result: 42)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesErrorIfResultConversionFails() {
        let invocationHandler = InvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.unsupportedType))
        })

        let completionMessage = CompletionMessage(invocationId: "", result: "42")
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatRaiseErrorPassesError() {
        let invocationHandler = InvocationHandler<Any>(typeConverter: JSONTypeConverter(), logger: NullLogger(), invocationDidComplete: { result, error in
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

    func testThatInvocationHandlerCreatesInvocationMessage() {
        let invocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in })
        let invocationMessage = invocationHandler.createInvocationMessage(invocationId: "42", method: "testMethod", arguments:[1, "abc"]) as? StreamInvocationMessage
        XCTAssertNotNil(invocationMessage)
        XCTAssertEqual(MessageType.StreamInvocation, invocationMessage!.messageType)
        XCTAssertEqual("42", invocationMessage!.invocationId)
        XCTAssertEqual("testMethod", invocationMessage!.target)
        XCTAssertEqual(2, invocationMessage!.arguments.count)
        XCTAssertEqual(1, invocationMessage!.arguments[0] as? Int)
        XCTAssertEqual("abc", invocationMessage!.arguments[1] as? String)
    }

    func testThatInvocationInvokesCallbackForStreamItem() {
        var receivedItem = -1
        let invocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), streamItemReceived: { item in receivedItem = 7}, invocationDidComplete: { error in XCTFail()})
        let error = invocationHandler.processStreamItem(streamItemMessage: StreamItemMessage(invocationId: "42", item: 7)) as? SignalRError
        XCTAssertNil(error)
        XCTAssertEqual(7, receivedItem)
    }

    func testThatInvocationReturnsErrorIfProcessingStreamItemFails() {
        let invocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), streamItemReceived: { item in XCTFail()}, invocationDidComplete: { error in XCTFail()})
        if let error = invocationHandler.processStreamItem(streamItemMessage: StreamItemMessage(invocationId: "42", item: "abc")) as? SignalRError {
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.unsupportedType))
        } else {
            XCTFail()
        }
    }

    func testThatInvocationHandlerPassesErrorForErrorCompletionMessage() {
        let streamInvocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in
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
        let streamInvocationHandler = StreamInvocationHandler<Int>(typeConverter: JSONTypeConverter(), logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNil(error)
        })

        let completionMessage = CompletionMessage(invocationId: "")
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatRaiseErrorPassesError() {
        let streamInvocationHandler = StreamInvocationHandler<Any>(typeConverter: JSONTypeConverter(), logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
        })

        streamInvocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
    }
}
