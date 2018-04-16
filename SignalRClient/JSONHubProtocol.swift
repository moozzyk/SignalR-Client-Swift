//
//  JSONHubProtocol.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 8/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class JSONTypeConverter: TypeConverter {
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
    private let recordSeparator = UInt8(0x1e)
    public let typeConverter: TypeConverter
    public let name = "json"
    public let version = 1
    public let type = ProtocolType.Text

    public convenience init() {
        self.init(typeConverter: JSONTypeConverter())
    }

    public init(typeConverter: TypeConverter) {
        self.typeConverter = typeConverter
    }

    public func parseMessages(input: Data) throws -> [HubMessage] {
        let payloads = input.split(separator: recordSeparator)
        // do not try to parse the last payload if it is not terminated with record sparator
        // TODO: log that if payloads was received ?
        var count = payloads.count
        if count > 0 && input.last != recordSeparator {
            count = count - 1
        }
        return try payloads[0..<count].map{ try createHubMessage(payload: $0) }
    }

    private func createHubMessage(payload: Data) throws -> HubMessage {
        let json = try JSONSerialization.jsonObject(with: payload)

        if let message = json as? NSDictionary, let rawMessageType = message.object(forKey: "type") as? Int, let messageType = MessageType(rawValue: rawMessageType) {
            switch messageType {
            case .Invocation:
                return try createInvocationMessage(message: message)
            case .StreamItem:
                return try createStreamItemMessage(message: message)
            case .Completion:
                return try createCompletionMessage(message: message)
            case .Ping:
                return PingMessage.instance
            default:
                print("Unsupported messageType: \(messageType)")
            }
        }

        throw SignalRError.unknownMessageType
    }

    private func createInvocationMessage(message: NSDictionary) throws -> InvocationMessage {
        // client side invocations are never blocking so the server never sends invocationId
        guard let target = message.value(forKey: "target") as? String else {
            throw SignalRError.invalidMessage
        }

        let arguments = message.object(forKey: "arguments") as? NSArray
        return InvocationMessage(target: target, arguments: arguments as? [Any?] ?? [])
    }

    private func createStreamItemMessage(message: NSDictionary) throws -> StreamItemMessage {
        let invocationId = try getInvocationId(message: message)
        return StreamItemMessage(invocationId: invocationId, item: message.value(forKey: "item"))
    }

    private func createCompletionMessage(message: NSDictionary) throws -> CompletionMessage {
        let invocationId = try getInvocationId(message: message)
        if let error = message.value(forKey: "error") as? String {
            return CompletionMessage(invocationId: invocationId, error: error)
        }

        if let result = message.value(forKey: "result") {
            return CompletionMessage(invocationId: invocationId, result: result is NSNull ? nil : result)
        }

        return CompletionMessage(invocationId: invocationId)
    }

    private func getInvocationId(message: NSDictionary) throws -> String {
        guard let invocationId = message.value(forKey: "invocationId") as? String else {
            throw SignalRError.invalidMessage
        }

        return invocationId
    }

    public func writeMessage(message: HubMessage) throws -> Data {
        let invocationJSONObject = try createMessageJSONObject(message: message)
        var payload = try JSONSerialization.data(withJSONObject: invocationJSONObject)
        payload.append(recordSeparator)
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
            "arguments": try streamInvocationMessage.arguments.map{ arg -> Any? in
                return try typeConverter.convertToWireType(obj: arg)
            }]
    }

    private func createCancelInvocationMessageJSONObject(cancelInvocationMessage: CancelInvocationMessage) -> [String: Any] {
        return [
            "type": cancelInvocationMessage.messageType.rawValue,
            "invocationId": cancelInvocationMessage.invocationId
        ]
    }
}
