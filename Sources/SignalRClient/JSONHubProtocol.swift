//
//  JSONHubProtocol.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 8/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

open class JSONTypeConverter: TypeConverter {
    public init() {}

    public func convertToWireType(obj: Any?) throws -> Any? {
        if isKnownType(obj: obj) || JSONSerialization.isValidJSONObject(obj!) {
            return obj
        }

        throw SignalRError.unsupportedType
    }

    private func isKnownType(obj: Any?) -> Bool {
        return obj == nil ||
            obj is Int || obj is Int? || obj is [Int] || obj is [Int?] ||
            obj is Double || obj is Double? || obj is [Double] || obj is [Double?] ||
            obj is String || obj is String? || obj is [String] || obj is [String?] ||
            obj is Bool || obj is Bool? || obj is [Bool] || obj is [Bool?];
    }

    public func convertFromWireType<T>(obj:Any?, targetType: T.Type) throws -> T? {
        if obj == nil || obj is NSNull {
            return nil
        }

        if let converted = obj as? T? {
            return converted
        }

        throw SignalRError.unsupportedType
    }
}

public class JSONHubProtocol: HubProtocol {
    private static let recordSeparator = UInt8(0x1e)
    private let logger: Logger
    public let typeConverter: TypeConverter
    public let name = "json"
    public let version = 1
    public let type = ProtocolType.Text


    public init(typeConverter: TypeConverter = JSONTypeConverter(), logger: Logger) {
        self.typeConverter = typeConverter
        self.logger = logger
    }

    public func parseMessages(input: Data) throws -> [HubMessage] {
        let payloads = input.split(separator: JSONHubProtocol.recordSeparator)
        // do not try to parse the last payload if it is not terminated with record sparator
        var count = payloads.count
        if count > 0 && input.last != JSONHubProtocol.recordSeparator {
            logger.log(logLevel: .warning, message: "Partial message received. Here be dragons...")
            count = count - 1
        }

        logger.log(logLevel: .debug, message: "Payload contains \(count) message(s)")

        return try payloads[0..<count].map{ try createHubMessage(payload: $0) }
    }

    private func createHubMessage(payload: Data) throws -> HubMessage {
        logger.log(logLevel: .debug, message: "Message received: \(String(data:payload, encoding: .utf8) ?? "(empty)")")

        let json = try JSONSerialization.jsonObject(with: payload)

        if let message = json as? [String: Any], let rawMessageType = message["type"] as? Int, let messageType = MessageType(rawValue: rawMessageType) {
            switch messageType {
            case .Invocation:
                return try createInvocationMessage(message: message)
            case .StreamItem:
                return try createStreamItemMessage(message: message)
            case .Completion:
                return try createCompletionMessage(message: message)
            case .Ping:
                return PingMessage.instance
            case .Close:
                return createCloseMessage(message: message)
            default:
                logger.log(logLevel: .error, message: "Unsupported messageType: \(messageType)")
            }
        }

        throw SignalRError.unknownMessageType
    }

    private func createInvocationMessage(message: [String: Any]) throws -> InvocationMessage {
        // client side invocations are never blocking so the server never sends invocationId
        guard let target = message["target"] as? String else {
            throw SignalRError.invalidMessage
        }

        let arguments = message["arguments"] as? [Any]
        return InvocationMessage(target: target, arguments: arguments ?? [])
    }

    private func createStreamItemMessage(message: [String: Any]) throws -> StreamItemMessage {
        let invocationId = try getInvocationId(message: message)
        return StreamItemMessage(invocationId: invocationId, item: message["item"] as Any)
    }

    private func createCompletionMessage(message: [String: Any]) throws -> CompletionMessage {
        let invocationId = try getInvocationId(message: message)
        if let error = message["error"] as? String {
            return CompletionMessage(invocationId: invocationId, error: error)
        }

        if let result = message["result"] {
            return CompletionMessage(invocationId: invocationId, result: result is NSNull ? nil : result)
        }

        return CompletionMessage(invocationId: invocationId)
    }

    private func getInvocationId(message: [String: Any]) throws -> String {
        guard let invocationId = message["invocationId"] as? String else {
            throw SignalRError.invalidMessage
        }

        return invocationId
    }

    private func createCloseMessage(message: [String: Any]) -> CloseMessage {
        let error = message["error"] as? String
        return CloseMessage(error: error)
    }

    public func writeMessage(message: HubMessage) throws -> Data {
        let invocationJSONObject = try createMessageJSONObject(message: message)
        var payload = try JSONSerialization.data(withJSONObject: invocationJSONObject)
        payload.append(JSONHubProtocol.recordSeparator)
        return payload
    }

    private func createMessageJSONObject(message: HubMessage) throws -> [String: Any] {
        switch message.messageType {
        case .Invocation:
            return try createInvocationMessageJSONObject(invocationMessage: message as! InvocationMessage)
        case .StreamInvocation:
            return try createStreamInvocationMessageJSONObject(streamInvocationMessage: message as!StreamInvocationMessage)
        case .CancelInvocation:
            return createCancelInvocationMessageJSONObject(cancelInvocationMessage: message as! CancelInvocationMessage)
        default:
            throw SignalRError.invalidOperation(message: "Unexpected MessageType.")
        }
    }

    private func createInvocationMessageJSONObject(invocationMessage: InvocationMessage) throws -> [String:Any] {
        var invocationJSONObject: [String: Any] = [
            "type": invocationMessage.messageType.rawValue,
            "target": invocationMessage.target,
            "arguments": try invocationMessage.arguments.map{ arg -> Any? in
                return try typeConverter.convertToWireType(obj: arg)
            }]
        if (invocationMessage.invocationId != nil) {
            invocationJSONObject["invocationId"] = invocationMessage.invocationId
        }
        return invocationJSONObject
    }

    private func createStreamInvocationMessageJSONObject(streamInvocationMessage: StreamInvocationMessage) throws -> [String:Any] {
        return [
            "type": streamInvocationMessage.messageType.rawValue,
            "invocationId": streamInvocationMessage.invocationId,
            "target": streamInvocationMessage.target,
            "arguments": try streamInvocationMessage.arguments.map{try typeConverter.convertToWireType(obj: $0)}]
    }

    private func createCancelInvocationMessageJSONObject(cancelInvocationMessage: CancelInvocationMessage) -> [String: Any] {
        return [
            "type": cancelInvocationMessage.messageType.rawValue,
            "invocationId": cancelInvocationMessage.invocationId
        ]
    }
}
