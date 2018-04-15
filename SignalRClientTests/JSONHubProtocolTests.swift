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

    func testThatHubProtocolReturnsCorrectVersion() {
        XCTAssertEqual(1, JSONHubProtocol().version)
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
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: "{ \"type\": false }\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.unknownMessageType))
        }
    }

    func testThatParsingFailsIfMessageTypeIsOutOfRange() {
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: "{ \"messageType\": 42 }\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.unknownMessageType))
        }
    }

    func testThatCanParseInvocationMessage() {
        let payload = "{ \"type\": 1, \"target\": \"method\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! InvocationMessage
        XCTAssertEqual(MessageType.Invocation, msg.messageType)
        XCTAssertNil(msg.invocationId)
        XCTAssertEqual("method", msg.target)
    }

    func testThatParsingInvocationMessageFailsIfInvocationIdMissing() {
        testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType.Invocation)
    }

    func testThatParsingInvocationMessageFailsIfInvocationIdNotString() {
        testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType.Invocation)
    }

    func testThatCanParseStreamItemMessage() {
        let payload = "{ \"type\": 2, \"invocationId\": \"12\" }\u{001e}"

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
        let payload = "{ \"type\": 3, \"invocationId\": \"12\", \"error\": \"Error occurred\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertEqual("Error occurred", msg.error)
        XCTAssertFalse(msg.hasResult)
        XCTAssertNil(msg.result)
    }

    func testThatCanParseVoidCompletionMessage() {
        let payload = "{ \"type\": 3, \"invocationId\": \"12\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertFalse(msg.hasResult)
        XCTAssertNil(msg.error)
        XCTAssertNil(msg.result)
    }

    func testThatCanParseNonVoidCompletionMessage() {
        let payload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": 42 }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertTrue(msg.hasResult)
        XCTAssertEqual(42, msg.result as! Int)
        XCTAssertNil(msg.error)
    }

    func testThatCanParseCompletionMessageWithNullResult() {
        let payload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": null }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.messageType)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertTrue(msg.hasResult)
        XCTAssertNil(nil)
        XCTAssertNil(msg.error)
    }

    func testThatParsingCompletionMessageFailsIfInvocationIdMissing() {
        testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType.Completion)
    }

    func testThatParsingCompletionMessageFailsIfInvocationIdNotString() {
        testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType.Completion)
    }

    private func testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType) {
        let payload =  "{ \"type\": \(messageType.rawValue) }\u{001e}"
        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidMessage))
        }
    }

    private func testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType) {
        let payload = "{ \"type\": \(messageType.rawValue), \"invocationId\": false }\u{001e}"

        XCTAssertThrowsError(try JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidMessage))
        }
    }

    func testThatCanParsePingMessage() {
        let payload = "{ \"type\": 6 }\u{001e}"

        let hubMessages = try! JSONHubProtocol().parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        XCTAssertEqual(MessageType.Ping, hubMessages[0].messageType)
    }

    func testThatCanWriteInvocationMessage() {
        let invocationMessage = InvocationMessage(invocationId: "12", target: "myMethod", arguments: [])
        let payload = try! JSONHubProtocol().writeMessage(message: invocationMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? NSDictionary)!

        XCTAssertEqual(1, json["type"] as! Int)
        XCTAssertEqual("12", json["invocationId"] as! String)
        XCTAssertEqual("myMethod", json["target"] as! String)
    }

    func testThatCanWriteInvocationMessageWithoutInvocationId() {
        let invocationMessage = InvocationMessage(target: "myMethod", arguments: [])
        let message = try! JSONHubProtocol().writeMessage(message: invocationMessage)

        let deserializedMessage = try! JSONHubProtocol().parseMessages(input: message)[0] as! InvocationMessage

        XCTAssertEqual(invocationMessage.messageType, deserializedMessage.messageType)
        XCTAssertNil(deserializedMessage.invocationId)
        XCTAssertEqual(invocationMessage.target, deserializedMessage.target)
    }

    func testThatCanWriteStreamInvocationMessage() {
        let streamInvocationMessage = StreamInvocationMessage(invocationId: "12", target: "myMethod", arguments: [])
        let payload = try! JSONHubProtocol().writeMessage(message: streamInvocationMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? NSDictionary)!

        XCTAssertEqual(4, json["type"] as! Int)
        XCTAssertEqual("12", json["invocationId"] as! String)
        XCTAssertEqual("myMethod", json["target"] as! String)
    }

    func testThatCanWriteCancelInvocationMessage() {
        let cancelInvocationMessage = CancelInvocationMessage(invocationId: "42")
        let payload = try! JSONHubProtocol().writeMessage(message: cancelInvocationMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? NSDictionary)!

        XCTAssertEqual(5, json["type"] as! Int)
        XCTAssertEqual("42", json["invocationId"] as! String)
    }

    func testThatWritingStreamItemMessageIsNotSupported() {
        let streamItemMessage = StreamItemMessage(invocationId: "12", item: nil)

        XCTAssertThrowsError(try JSONHubProtocol().writeMessage(message: streamItemMessage)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidOperation(message: "Unexpected MessageType.")))
        }
    }

    func testThatWritingCompletionMessageIsNotSupported() {
        let completionMessage = CompletionMessage(invocationId: "12")

        XCTAssertThrowsError(try JSONHubProtocol().writeMessage(message: completionMessage)) {
            error in XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidOperation(message: "Unexpected MessageType.")))
        }
    }
}
