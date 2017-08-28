//
//  JSONHubProtocolTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 9/2/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class JSONHubProtocolTests: XCTestCase {
    func testThatHubProtocolReturnsCorrectName() {
        XCTAssertEqual("json", JSONHubProtocol().name)
    }

    func testThatMessagesWithoutSeparatorAreNotParsed() {
        XCTAssertEqual(0, try JSONHubProtocol().parseMessages(input: "abc".data(using: .utf8)!).count)
    }

    func testThatParsingFailsIfMessageNotValidJson() {
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: "abc\u{1e}".data(using: .utf8)!))
    }

    func testThatParsingFailsIfMessageTypeIsMissing() {
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: "{}\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.unknownMessageType))
        }
    }

    func testThatParsingFailsIfMessageTypeIsNotNumber() {
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: "{ \"messageType\": false }\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.unknownMessageType))
        }
    }

    func testThatParsingFailsIfMessageTypeIsOutOfRange() {
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: "{ \"messageType\": 42 }\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.unknownMessageType))
        }
    }

    func testThatCanParseInvocationMessage() {
        let payload = "{ \"messageType\": 1, \"invocationId\": \"12\", \"target\": \"method\", \"nonBlocking\": true }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! InvocationMessage
        XCTAssertEqual(MessageType.Invocation, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertEqual("method", msg.target)
        XCTAssertTrue(msg.nonBlocking)
    }

    func testThatCanParseInvocationMessageWithoutNonBlocking() {
        let payload = "{ \"messageType\": 1, \"invocationId\": \"12\", \"target\": \"method\"}\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! InvocationMessage
        XCTAssertEqual(MessageType.Invocation, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertEqual("method", msg.target)
        XCTAssertFalse(msg.nonBlocking)
    }

    func testThatParsingInvocationMessageFailsIfInvocationIdMissing() {
        testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType.Invocation)
    }

    func testThatParsingInvocationMessageFailsIfInvocationIdNotString() {
        testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType.Invocation)
    }

    func testThatCanParseStreamItemMessage() {
        let payload = "{ \"messageType\": 2, \"invocationId\": \"12\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! StreamItemMessage
        XCTAssertEqual(MessageType.StreamItem, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
    }

    func testThatParsingStreamItemMessageFailsIfInvocationIdMissing() {
        testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType.StreamItem)
    }

    func testThatParsingStreamItemMessageFailsIfInvocationIdNotString() {
        testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType.StreamItem)
    }

    func testThatCanParseCompletionErrorMessage() {
        let payload = "{ \"messageType\": 3, \"invocationId\": \"12\", \"error\": \"Error occurred\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertEqual("Error occurred", msg.error)
        XCTAssertNil(msg.hasResult)
        XCTAssertNil(msg.result)
    }

    func testThatCanParseVoidCompletionMessage() {
        let payload = "{ \"messageType\": 3, \"invocationId\": \"12\", \"hasResult\": false }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertFalse(msg.hasResult!)
        XCTAssertNil(msg.error)
        XCTAssertNil(msg.result)
    }

    func testThatCanParseNonVoidCompletionMessage() {
        let payload = "{ \"messageType\": 3, \"invocationId\": \"12\", \"hasResult\": true, \"result\": 42 }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertTrue(msg.hasResult!)
        // TODO: !!!!
        // XCTAssertEqual(42, msg.result as Int!)
        XCTAssertNil(msg.error)
    }

    func testThatParsingCompletionMessageFailsIfInvocationIdMissing() {
        testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType.Completion)
    }

    func testThatParsingCompletionMessageFailsIfInvocationIdNotString() {
        testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType.Completion)
    }

    func testThatParsingCompletionMessageFailsIfNoErrorOrResult() {
        let payload =  "{ \"messageType\": 3, \"invocationId\": \"12\" }\u{001e}"

        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidMessage))
        }
    }

    private func testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType) {
        let payload =  "{ \"messageType\": \(messageType.rawValue) }\u{001e}"
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidMessage))
        }
    }

    private func testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType) {
        let payload = "{ \"messageType\": \(messageType.rawValue), \"invocationId\": false }\u{001e}"

        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidMessage))
        }
    }

    func testThatCanWriteInvocationMessage() {
        let invocationMessage = InvocationMessage(invocationId: "12", target: "myMethod", arguments: [], nonBlocking: true)
        var message = try! JSONHubProtocol().writeMessage(message: invocationMessage)
        message.append("\u{1e}".data(using: .utf8)!)
        let deserializedMessage = try! JSONHubProtocol().parseMessages(input: message)[0] as! InvocationMessage

        XCTAssertEqual(invocationMessage.messageType, deserializedMessage.messageType)
        XCTAssertEqual(invocationMessage.invocationId, deserializedMessage.invocationId)
        XCTAssertEqual(invocationMessage.target, deserializedMessage.target)
        XCTAssertEqual(invocationMessage.nonBlocking, deserializedMessage.nonBlocking)

    }

    func testThatWritingStreamItemMessageIsNotSupported() {
        let streamItemMessage = StreamItemMessage(invocationId: "12", item: nil)

        XCTAssertThrowsError(try JSONHubProtocol().writeMessage(message: streamItemMessage)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidOperation(message: "Unexpected messageType.")))
        }
    }

    func testThatWritingCompletionMessageIsNotSupported() {
        let completionMessage = CompletionMessage(invocationId: "12")

        XCTAssertThrowsError(try JSONHubProtocol().writeMessage(message: completionMessage)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidOperation(message: "Unexpected messageType.")))
        }
    }
}
