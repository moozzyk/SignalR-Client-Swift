//
//  HubProtocol.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 8/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ProtocolType: Int {
    case Text = 1
    case Binary
}

public protocol HubProtocol {
    var name: String { get }
    var type: ProtocolType { get }
    var typeConverter: TypeConverter { get }
    func parseMessages(input: Data) throws -> [HubMessage]
    func writeMessage(message: HubMessage) throws -> Data
}

public enum MessageType: Int {
    case Invocation = 1
    case StreamItem
    case Completion
}

public protocol HubMessage {
    var messageType: MessageType { get }
}

public class InvocationMessage: HubMessage {
    public let messageType = MessageType.Invocation
    public let invocationId: String?
    public let target: String
    public let arguments: [Any?]

    init(target: String, arguments: [Any?]) {
        self.invocationId = nil
        self.target = target
        self.arguments = arguments
    }

    init(invocationId: String, target: String, arguments: [Any?]) {
        self.invocationId = invocationId
        self.target = target
        self.arguments = arguments
    }
}

public class StreamItemMessage: HubMessage {
    public let messageType = MessageType.StreamItem
    public let invocationId: String
    public let item: Any?

    init(invocationId: String, item: Any?) {
        self.invocationId = invocationId
        self.item = item
    }
}

public class CompletionMessage: HubMessage {
    public let messageType = MessageType.Completion
    public let invocationId: String
    public let error: String?
    public let hasResult: Bool
    public let result: Any?

    init(invocationId: String) {
        self.invocationId = invocationId
        self.result = nil
        self.error = nil
        self.hasResult = false
    }

    init(invocationId: String, result: Any?) {
        self.invocationId = invocationId
        self.result = result
        self.error = nil
        self.hasResult = true
    }

    init(invocationId: String, error: String) {
        self.invocationId = invocationId
        self.error = error
        self.result = nil
        self.hasResult = false
    }
}
