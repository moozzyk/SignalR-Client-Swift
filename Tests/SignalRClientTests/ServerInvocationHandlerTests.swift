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

    func testThatInvocationHandlerCreatesInvocationMessage() {
        let invocationHandler = InvocationHandler<Int>(logger: NullLogger(), invocationDidComplete: { result, error in })
        let invocationMessage = invocationHandler.createInvocationMessage(invocationId: "42", method: "testMethod", arguments: [1, "abc"], streamIds: ["1", "2"]) as? ServerInvocationMessage
        XCTAssertNotNil(invocationMessage)
        XCTAssertEqual(MessageType.Invocation, invocationMessage!.type)
        XCTAssertEqual("42", invocationMessage!.invocationId)
        XCTAssertEqual("testMethod", invocationMessage!.target)
        XCTAssertEqual(2, invocationMessage!.arguments.count)
        XCTAssertEqual(1, invocationMessage!.arguments[0] as? Int)
        XCTAssertEqual("abc", invocationMessage!.arguments[1] as? String)
        XCTAssertEqual(2, invocationMessage!.streamIds?.count ?? 0)
        XCTAssertEqual("1", invocationMessage!.streamIds![0])
        XCTAssertEqual("2", invocationMessage!.streamIds![1])
    }

    func testThatInvocationHandlerReturnsErrorForStreamItem() {
        let invocationHandler = InvocationHandler<Int>(logger: NullLogger(), invocationDidComplete: { result, error in })
        let messagePayload = "{ \"type\": 2, \"invocationId\": \"42\", \"item\": \"abc\" }".data(using: .utf8)!
        let streamItemMessage = try! JSONDecoder().decode(StreamItemMessage.self, from: messagePayload)

        if let error = invocationHandler.processStreamItem(streamItemMessage: streamItemMessage) as? SignalRError {
            switch error {
            case SignalRError.protocolViolation:
                break
            default:
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }

    func testThatInvocationHandlerPassesErrorForErrorCompletionMessage() {
        let invocationHandler = InvocationHandler<Int>(logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error as! SignalRError), String(describing: SignalRError.hubInvocationError(message: "Error occurred!")))
        })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"error\": \"Error occurred!\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesNilAsResultForVoidCompletionMessage() {
        let invocationHandler = InvocationHandler<DecodableVoid>(logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(error)
            XCTAssertNil(result)
        })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesValueForResultCompletionMessage() {
        let invocationHandler = InvocationHandler<Int>(logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(42, result)
        })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": 42 }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesErrorIfResultConversionFails() {
        let invocationHandler = InvocationHandler<Int>(logger: NullLogger(), invocationDidComplete: { result, error in
            XCTAssertNil(result)
            switch (error as! SignalRError) {
            case SignalRError.serializationError:
                break
            default:
                XCTFail()
            }
        })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": \"abc\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatRaiseErrorPassesError() {
        let invocationHandler = InvocationHandler<String>(logger: NullLogger(), invocationDidComplete: { result, error in
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
        let invocationHandler = StreamInvocationHandler<Int>(logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in })
        let invocationMessage = invocationHandler.createInvocationMessage(invocationId: "42", method: "testMethod", arguments: [1, "abc"], streamIds: ["1", "2"]) as? StreamInvocationMessage
        XCTAssertNotNil(invocationMessage)
        XCTAssertEqual(MessageType.StreamInvocation, invocationMessage!.type)
        XCTAssertEqual("42", invocationMessage!.invocationId)
        XCTAssertEqual("testMethod", invocationMessage!.target)
        XCTAssertEqual(2, invocationMessage!.arguments.count)
        XCTAssertEqual(1, invocationMessage!.arguments[0] as? Int)
        XCTAssertEqual("abc", invocationMessage!.arguments[1] as? String)
        XCTAssertEqual(2, invocationMessage!.streamIds?.count ?? 0)
        XCTAssertEqual("1", invocationMessage!.streamIds![0])
        XCTAssertEqual("2", invocationMessage!.streamIds![1])
    }

    func testThatInvocationInvokesCallbackForStreamItem() {
        var receivedItem = -1
        let invocationHandler = StreamInvocationHandler<Int>(logger: NullLogger(), streamItemReceived: { item in receivedItem = 7}, invocationDidComplete: { error in XCTFail()})

        let messagePayload = "{ \"type\": 2, \"invocationId\": \"42\", \"item\": 7 }".data(using: .utf8)!
        let streamItemMessage = try! JSONDecoder().decode(StreamItemMessage.self, from: messagePayload)

        let error = invocationHandler.processStreamItem(streamItemMessage: streamItemMessage) as? SignalRError
        XCTAssertNil(error)
        XCTAssertEqual(7, receivedItem)
    }

    func testThatInvocationReturnsErrorIfProcessingStreamItemFails() {
        let invocationHandler = StreamInvocationHandler<Int>(logger: NullLogger(), streamItemReceived: { item in XCTFail()}, invocationDidComplete: { error in XCTFail()})

        let messagePayload = "{ \"type\": 2, \"invocationId\": \"42\", \"item\": \"abc\" }".data(using: .utf8)!
        let streamItemMessage = try! JSONDecoder().decode(StreamItemMessage.self, from: messagePayload)

        if let error = invocationHandler.processStreamItem(streamItemMessage: streamItemMessage) as? SignalRError {
            switch (error) {
            case SignalRError.serializationError:
                break
            default:
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }

    func testThatInvocationHandlerPassesErrorForErrorCompletionMessage() {
        let streamInvocationHandler = StreamInvocationHandler<Int>(logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertEqual(String(describing: error as! SignalRError), String(describing: SignalRError.hubInvocationError(message: "Error occurred!")))
        })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"error\": \"Error occurred!\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesNilAsResultForVoidCompletionMessage() {
        let streamInvocationHandler = StreamInvocationHandler<Int>(logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNil(error)
        })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatRaiseErrorPassesError() {
        let streamInvocationHandler = StreamInvocationHandler<String>(logger: NullLogger(), streamItemReceived: { item in }, invocationDidComplete: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
        })

        streamInvocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
    }
}
