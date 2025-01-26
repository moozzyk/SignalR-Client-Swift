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
    private let callbackQueue = DispatchQueue(label: "SignalR.tests")

    func testThatInvocationHandlerCreatesInvocationMessage() {
        let severStreamWorkers = [TestClientStreamWorker(streamId: "5"), TestClientStreamWorker(streamId: "42")]
        let invocationHandler = InvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "testMethod", arguments: [1, "abc"],
            clientStreamWorkers: severStreamWorkers,
            invocationDidComplete: { result, error in })
        let invocationMessage =
            invocationHandler.createInvocationMessage(invocationId: "42") as? ServerInvocationMessage
        XCTAssertNotNil(invocationMessage)
        XCTAssertEqual(MessageType.Invocation, invocationMessage!.type)
        XCTAssertEqual("42", invocationMessage!.invocationId)
        XCTAssertEqual("testMethod", invocationMessage!.target)
        XCTAssertEqual(2, invocationMessage!.arguments.count)
        XCTAssertEqual(1, invocationMessage!.arguments[0] as? Int)
        XCTAssertEqual("abc", invocationMessage!.arguments[1] as? String)
        XCTAssertEqual(["5", "42"], invocationMessage!.streamIds)
    }

    func testThatInvocationHandlerReturnsErrorForStreamItem() {
        let invocationHandler = InvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            invocationDidComplete: { result, error in })
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
        let invocationHandler = InvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            invocationDidComplete: { result, error in
                XCTAssertNil(result)
                XCTAssertNotNil(error)
                XCTAssertEqual(
                    String(describing: error as! SignalRError),
                    String(describing: SignalRError.hubInvocationError(message: "Error occurred!")))
            })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"error\": \"Error occurred!\" }".data(
            using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesNilAsResultForVoidCompletionMessage() {
        let invocationHandler = InvocationHandler<DecodableVoid>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            invocationDidComplete: { result, error in
                XCTAssertNil(error)
                XCTAssertNil(result)
            })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesValueForResultCompletionMessage() {
        let stream1StopExpectation = expectation(description: "stream 1 stopped")
        let stream2StopExpectation = expectation(description: "stream 2 stopped")
        let clientStreamWorkers = [
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream1StopExpectation.fulfill() }),
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream2StopExpectation.fulfill() }),
        ]

        let invocationHandler = InvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [],
            clientStreamWorkers: clientStreamWorkers,
            invocationDidComplete: { result, error in
                XCTAssertNil(error)
                XCTAssertEqual(42, result)
            })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": 42 }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        invocationHandler.processCompletion(completionMessage: completionMessage)
        waitForExpectations(timeout: 5)
    }

    func testThatInvocationHandlerPassesErrorIfResultConversionFails() {
        let invocationHandler = InvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            invocationDidComplete: { result, error in
                XCTAssertNil(result)
                switch error as! SignalRError {
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
        let invocationHandler = InvocationHandler<String>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            invocationDidComplete: { result, error in
                XCTAssertNil(result)
                XCTAssertNotNil(error)
                XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
            })

        invocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
    }

    func testThatRaiseErrorStopsStreams() {
        let stream1StopExpectation = expectation(description: "stream 1 stopped")
        let stream2StopExpectation = expectation(description: "stream 2 stopped")
        let clientStreamWorkers = [
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream1StopExpectation.fulfill() }),
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream2StopExpectation.fulfill() }),
        ]

        let invocationHandler = InvocationHandler<String>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [],
            clientStreamWorkers: clientStreamWorkers,
            invocationDidComplete: { result, error in
                XCTAssertNil(result)
                XCTAssertNotNil(error)
                XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
            })

        invocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
        waitForExpectations(timeout: 5)
    }

    func testThatStartStreamsStartsStreams() {
        let stream1StartExpectation = expectation(description: "stream 1 started")
        let stream2StartExpectation = expectation(description: "stream 2 started")
        let clientStreamWorkers = [
            TestClientStreamWorker(streamId: "5", startHandler: { stream1StartExpectation.fulfill() }, stopHandler: {}),
            TestClientStreamWorker(streamId: "7", startHandler: { stream2StartExpectation.fulfill() }, stopHandler: {}),
        ]

        let streamInvocationHandler = InvocationHandler<String>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [],
            clientStreamWorkers: clientStreamWorkers,
            invocationDidComplete: { result, error in })

        streamInvocationHandler.startStreams()

        waitForExpectations(timeout: 5)
    }
}

class StreamInvocationHandlerTests: XCTestCase {
    private let callbackQueue = DispatchQueue(label: "SignalR.tests")

    func testThatInvocationHandlerCreatesInvocationMessage() {
        let severStreamWorkers = [TestClientStreamWorker(streamId: "5"), TestClientStreamWorker(streamId: "42")]
        let invocationHandler = StreamInvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "testMethod", arguments: [1, "abc"],
            clientStreamWorkers: severStreamWorkers,
            streamItemReceived: { item in }, invocationDidComplete: { error in })
        let invocationMessage =
            invocationHandler.createInvocationMessage(invocationId: "42") as? StreamInvocationMessage
        XCTAssertNotNil(invocationMessage)
        XCTAssertEqual(MessageType.StreamInvocation, invocationMessage!.type)
        XCTAssertEqual("42", invocationMessage!.invocationId)
        XCTAssertEqual("testMethod", invocationMessage!.target)
        XCTAssertEqual(2, invocationMessage!.arguments.count)
        XCTAssertEqual(1, invocationMessage!.arguments[0] as? Int)
        XCTAssertEqual("abc", invocationMessage!.arguments[1] as? String)
        XCTAssertEqual(["5", "42"], invocationMessage?.streamIds)
    }

    func testThatInvocationInvokesCallbackForStreamItem() {
        let streamItemReceivedExpectation = expectation(description: "stream item received")

        var receivedItem = -1
        let invocationHandler = StreamInvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            streamItemReceived: { item in
                receivedItem = 7
                streamItemReceivedExpectation.fulfill()
            }, invocationDidComplete: { error in XCTFail() })

        let messagePayload = "{ \"type\": 2, \"invocationId\": \"42\", \"item\": 7 }".data(using: .utf8)!
        let streamItemMessage = try! JSONDecoder().decode(StreamItemMessage.self, from: messagePayload)

        let error = invocationHandler.processStreamItem(streamItemMessage: streamItemMessage) as? SignalRError
        waitForExpectations(timeout: 5 /*seconds*/)
        XCTAssertNil(error)
        XCTAssertEqual(7, receivedItem)
    }

    func testThatInvocationReturnsErrorIfProcessingStreamItemFails() {
        let invocationHandler = StreamInvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            streamItemReceived: { item in XCTFail() }, invocationDidComplete: { error in XCTFail() })

        let messagePayload = "{ \"type\": 2, \"invocationId\": \"42\", \"item\": \"abc\" }".data(using: .utf8)!
        let streamItemMessage = try! JSONDecoder().decode(StreamItemMessage.self, from: messagePayload)

        if let error = invocationHandler.processStreamItem(streamItemMessage: streamItemMessage) as? SignalRError {
            switch error {
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
        let streamInvocationHandler = StreamInvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            streamItemReceived: { item in },
            invocationDidComplete: { error in
                XCTAssertEqual(
                    String(describing: error as! SignalRError),
                    String(describing: SignalRError.hubInvocationError(message: "Error occurred!")))
            })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\", \"error\": \"Error occurred!\" }".data(
            using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
    }

    func testThatInvocationHandlerPassesNilAsResultForVoidCompletionMessage() {
        let stream1StopExpectation = expectation(description: "stream 1 stopped")
        let stream2StopExpectation = expectation(description: "stream 2 stopped")
        let clientStreamWorkers = [
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream1StopExpectation.fulfill() }),
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream2StopExpectation.fulfill() }),
        ]

        let streamInvocationHandler = StreamInvocationHandler<Int>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [],
            clientStreamWorkers: clientStreamWorkers,
            streamItemReceived: { item in },
            invocationDidComplete: { error in
                XCTAssertNil(error)
            })

        let messagePayload = "{ \"type\": 3, \"invocationId\": \"12\" }".data(using: .utf8)!
        let completionMessage = try! JSONDecoder().decode(CompletionMessage.self, from: messagePayload)
        streamInvocationHandler.processCompletion(completionMessage: completionMessage)
        waitForExpectations(timeout: 5)
    }

    func testThatRaiseErrorPassesError() {
        let streamInvocationHandler = StreamInvocationHandler<String>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [], clientStreamWorkers: [],
            streamItemReceived: { item in },
            invocationDidComplete: { error in
                XCTAssertNotNil(error)
                XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
            })

        streamInvocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
    }

    func testThatRaiseErrorStopsStreams() {
        let stream1StopExpectation = expectation(description: "stream 1 stopped")
        let stream2StopExpectation = expectation(description: "stream 2 stopped")
        let clientStreamWorkers = [
            TestClientStreamWorker(streamId: "5", startHandler: {}, stopHandler: { stream1StopExpectation.fulfill() }),
            TestClientStreamWorker(streamId: "7", startHandler: {}, stopHandler: { stream2StopExpectation.fulfill() }),
        ]

        let streamInvocationHandler = StreamInvocationHandler<String>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [],
            clientStreamWorkers: clientStreamWorkers, streamItemReceived: { item in },
            invocationDidComplete: { error in
                XCTAssertNotNil(error)
                XCTAssertEqual(String(describing: error!), String(describing: SignalRError.hubInvocationCancelled))
            })

        streamInvocationHandler.raiseError(error: SignalRError.hubInvocationCancelled)
        waitForExpectations(timeout: 5)
    }

    func testThatStartStreamsStartsStreams() {
        let stream1StartExpectation = expectation(description: "stream 1 started")
        let stream2StartExpectation = expectation(description: "stream 2 started")
        let clientStreamWorkers = [
            TestClientStreamWorker(streamId: "5", startHandler: { stream1StartExpectation.fulfill() }, stopHandler: {}),
            TestClientStreamWorker(streamId: "7", startHandler: { stream2StartExpectation.fulfill() }, stopHandler: {}),
        ]

        let streamInvocationHandler = StreamInvocationHandler<String>(
            logger: NullLogger(), callbackQueue: callbackQueue, method: "test", arguments: [],
            clientStreamWorkers: clientStreamWorkers, streamItemReceived: { item in },
            invocationDidComplete: { error in })

        streamInvocationHandler.startStreams()

        waitForExpectations(timeout: 5)
    }
}

class TestClientStreamWorker: ClientStreamWorker {
    var streamId: String
    let startHandler: () -> Void
    let stopHandler: () -> Void

    init(streamId: String) {
        self.streamId = streamId
        self.startHandler = {}
        self.stopHandler = {}
    }

    init(streamId: String, startHandler: @escaping () -> Void, stopHandler: @escaping () -> Void) {
        self.streamId = streamId
        self.startHandler = startHandler
        self.stopHandler = stopHandler
    }

    func start() {
        startHandler()
    }

    func stop() {
        stopHandler()
    }
}
