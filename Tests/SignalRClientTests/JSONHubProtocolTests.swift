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
        XCTAssertEqual("json", JSONHubProtocol(logger: NullLogger()).name)
    }

    func testThatHubProtocolReturnsCorrectVersion() {
        XCTAssertEqual(1, JSONHubProtocol(logger: NullLogger()).version)
    }

    func testThatMessagesWithoutSeparatorAreNotParsed() {
        XCTAssertEqual(0, try JSONHubProtocol(logger: NullLogger()).parseMessages(input: "abc".data(using: .utf8)!).count)
    }

    func testThatParsingFailsIfMessageNotValidJson() {
        XCTAssertThrowsError(try JSONHubProtocol(logger: NullLogger()).parseMessages(input: "abc\u{1e}".data(using: .utf8)!))
    }

    func testThatParsingFailsIfMessageTypeIsMissing() {
        XCTAssertThrowsError(try JSONHubProtocol(logger: NullLogger()).parseMessages(input: "{}\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertTrue(JSONHubProtocolTests.isProtocolViolation(error))
        }
    }

    func testThatParsingFailsIfMessageTypeIsNotNumber() {
        XCTAssertThrowsError(try JSONHubProtocol(logger: NullLogger()).parseMessages(input: "{ \"type\": false }\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertTrue(JSONHubProtocolTests.isProtocolViolation(error))
        }
    }

    func testThatParsingFailsIfMessageTypeIsOutOfRange() {
        XCTAssertThrowsError(try JSONHubProtocol(logger: NullLogger()).parseMessages(input: "{ \"type\": 42 }\u{1e}".data(using: .utf8)!)) {
            error in XCTAssertTrue(JSONHubProtocolTests.isProtocolViolation(error))
        }
    }

    func testThatCanParseInvocationMessage() {
        let payload = "{ \"type\": 1, \"target\": \"method\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! ClientInvocationMessage
        XCTAssertEqual(MessageType.Invocation, msg.type)
        XCTAssertEqual("method", msg.target)
        XCTAssertFalse(msg.hasMoreArgs)
    }

    func testThatClientInvocationMessageGetArgumentThrowsIfNoArgs() {
        let payload = "{ \"type\": 1, \"target\": \"method\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! ClientInvocationMessage
        XCTAssertThrowsError(try msg.getArgument(type: String.self)) { error in
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidOperation(message: "No arguments exist.")))
        }
    }

    func testThatClientInvocationMessageHasMoreArgsReturnsCorrectValue() {
        let payload = "{ \"type\": 1, \"target\": \"method\", \"arguments\": [42, \"abc\"] }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! ClientInvocationMessage
        XCTAssertTrue(msg.hasMoreArgs)
        XCTAssertEqual(42, try! msg.getArgument(type: Int.self))
        XCTAssertTrue(msg.hasMoreArgs)
        XCTAssertEqual("abc", try! msg.getArgument(type: String.self))
        XCTAssertFalse(msg.hasMoreArgs)
    }

    func testThatParsingInvocationMessageFailsIfInvocationIdMissing() {
        testThatParsingMessageFailsIfInvocationIdMissing(messageType: MessageType.Invocation)
    }

    func testThatParsingInvocationMessageFailsIfInvocationIdNotString() {
        testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType.Invocation)
    }

    func testThatCanParseStreamItemMessage() {
        let payload = "{ \"type\": 2, \"invocationId\": \"12\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! StreamItemMessage
        XCTAssertEqual(MessageType.StreamItem, msg.type)
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

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.type)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertEqual("Error occurred", msg.error)
        XCTAssertFalse(msg.hasResult)
        XCTAssertNil(try msg.getResult(String.self))
    }

    func testThatCanParseVoidCompletionMessage() {
        let payload = "{ \"type\": 3, \"invocationId\": \"12\" }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.type)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertFalse(msg.hasResult)
        XCTAssertNil(msg.error)
        XCTAssertNil(try msg.getResult(String.self))
    }

    func testThatCanParseNonVoidCompletionMessage() {
        let payload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": 42 }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.type)
        XCTAssertEqual("12", msg.invocationId)
        XCTAssertTrue(msg.hasResult)
        XCTAssertEqual(42, try msg.getResult(Int.self))
        XCTAssertNil(msg.error)
    }

    func testThatCanParseCompletionMessageWithNullResult() {
        let payload = "{ \"type\": 3, \"invocationId\": \"12\", \"result\": null }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! CompletionMessage
        XCTAssertEqual(MessageType.Completion, msg.type)
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
        XCTAssertThrowsError(try JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertTrue(JSONHubProtocolTests.isProtocolViolation(error))
        }
    }

    private func testThatParsingMessageFailsIfInvocationIdNotString(messageType: MessageType) {
        let payload = "{ \"type\": \(messageType.rawValue), \"invocationId\": false }\u{001e}"

        XCTAssertThrowsError(try JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)) {
            error in XCTAssertTrue(JSONHubProtocolTests.isProtocolViolation(error))
        }
    }

    func testThatCanParsePingMessage() {
        let payload = "{ \"type\": 6 }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        XCTAssertEqual(MessageType.Ping, hubMessages[0].type)
    }

    func testThatCanParseCloseMessageWithoutError() {
        let payload = "{ \"type\": 7 }\u{001e}"
        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        XCTAssertEqual(MessageType.Close, hubMessages[0].type)
        XCTAssertNil((hubMessages[0] as! CloseMessage).error)
    }

    func testThatCanParseCloseMessageWithError() {
        let payload = "{ \"type\": 7, \"error\": \"Error occurred\" }\u{001e}"
        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        XCTAssertEqual(MessageType.Close, hubMessages[0].type)
        XCTAssertEqual("Error occurred", (hubMessages[0] as! CloseMessage).error)
    }

    func testThatCanWriteServerInvocationMessage() {
        let invocationMessage = ServerInvocationMessage(invocationId: "12", target: "myMethod", arguments: [], streamIds: [])
        let payload = try! JSONHubProtocol(logger: NullLogger()).writeMessage(message: invocationMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? [String: Any])!

        XCTAssertEqual(1, json["type"] as! Int)
        XCTAssertEqual("12", json["invocationId"] as! String)
        XCTAssertEqual("myMethod", json["target"] as! String)
    }

    func testThatCanWriteInvocationMessageWithoutInvocationId() {
        let invocationMessage = ServerInvocationMessage(target: "myMethod", arguments: [], streamIds: [])
        let message = try! JSONHubProtocol(logger: NullLogger()).writeMessage(message: invocationMessage)

        let deserializedMessage = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: message)[0] as! ClientInvocationMessage

        XCTAssertEqual(invocationMessage.type, deserializedMessage.type)
        XCTAssertEqual(invocationMessage.target, deserializedMessage.target)
    }

    func testThatCanWriteStreamInvocationMessage() {
        let streamInvocationMessage = StreamInvocationMessage(invocationId: "12", target: "myMethod", arguments: [], streamIds: [])
        let payload = try! JSONHubProtocol(logger: NullLogger()).writeMessage(message: streamInvocationMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? [String: Any])!

        XCTAssertEqual(4, json["type"] as! Int)
        XCTAssertEqual("12", json["invocationId"] as! String)
        XCTAssertEqual("myMethod", json["target"] as! String)
    }

    func testThatCanWriteCancelInvocationMessage() {
        let cancelInvocationMessage = CancelInvocationMessage(invocationId: "42")
        let payload = try! JSONHubProtocol(logger: NullLogger()).writeMessage(message: cancelInvocationMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? [String: Any])!

        XCTAssertEqual(5, json["type"] as! Int)
        XCTAssertEqual("42", json["invocationId"] as! String)
    }

    func testThatCanWriteStreamItemMessage() {
        let streamItemMessage = StreamItemMessage(invocationId: "12", item: 42)
        let payload = try! JSONHubProtocol(logger: NullLogger()).writeMessage(message: streamItemMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? [String: Any])!

        XCTAssertEqual(2, json["type"] as! Int)
        XCTAssertEqual("12", json["invocationId"] as! String)
        XCTAssertEqual(42, json["item"] as! Int)
    }

    func testThatCanWriteCompletionMessage() {
        let completionMessage = CompletionMessage(invocationId: "12", error: "Error occurred")
        let payload = try! JSONHubProtocol(logger: NullLogger()).writeMessage(message: completionMessage)
        let message = String(data: payload, encoding: .utf8)!
        let data = message[..<message.index(before: message.endIndex)].data(using: .utf8)
        let json = (try! JSONSerialization.jsonObject(with: data!) as? [String: Any])!

        XCTAssertEqual(3, json["type"] as! Int)
        XCTAssertEqual("12", json["invocationId"] as! String)
        XCTAssertEqual("Error occurred", json["error"] as! String)
    }

    private static func isProtocolViolation(_ error: Error) -> Bool {
        switch (error as! SignalRError) {
        case .protocolViolation:
            return true
        default:
            return false
        }
    }
}
