//
//  JSONInvocationSerializer.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/6/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class JSONTypeConverter: TypeConverter {
    public func convertToWireType(obj: Any?) throws -> Any? {
        if isKnownType(obj: obj) || JSONSerialization.isValidJSONObject(obj: obj!) {
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
        if obj == nil {
            return nil
        }

        if let converted = obj as? T? {
            return converted
        }

        throw SignalRError.unsupportedType
    }
}

public class JSONInvocationSerializer: InvocationSerializer {

    private let typeConverter: TypeConverter

    init(typeConverter: TypeConverter? = nil) {
        self.typeConverter = typeConverter ?? JSONTypeConverter()
    }

    public func writeInvocationDescriptor(invocationDescriptor: InvocationDescriptor) throws -> Data {
        let convertedArguments = try invocationDescriptor.arguments.map{ arg -> Any? in
            return try typeConverter.convertToWireType(obj: arg)
        }

        let payload: [String: Any] = [
            "Id": invocationDescriptor.id,
            "Method": invocationDescriptor.method,
            "Arguments": convertedArguments
        ];

        return try JSONSerialization.data(withJSONObject: payload)
    }

    public func processIncomingData(data: Data) throws -> AnyObject {
        let json = try JSONSerialization.jsonObject(with: data)
        if let message = json as? NSDictionary {
            if message.object(forKey: "Result") != nil {
                let id = message.object(forKey: "Id")
                let error = message.object(forKey: "Error")
                let result = message.object(forKey: "Result")
                return JSONInvocationResult(id: Int(id as! String)!, error: error as? String, result: result as Any?, typeConverter: typeConverter)
            }

            let rawArguments = message.object(forKey: "Arguments")
            if rawArguments == nil || rawArguments as? NSArray != nil {
                let method = message.object(forKey: "Method")
                let arguments = rawArguments as? NSArray
                return InvocationDescriptor(id: -1, method: method as! String, arguments: arguments as? [Any?] ?? [])
            }
        }

        throw SignalRError.unknownMessageType
    }
}

fileprivate class JSONInvocationResult: InvocationResult {
    let id: Int
    let error: String?
    let result: Any?
    let typeConverter: TypeConverter

    init(id: Int, error: String?, result: Any?, typeConverter: TypeConverter) {
        self.id = id
        self.error = error
        self.result = result
        self.typeConverter = typeConverter
    }

    func getResult<T>(type: T.Type) throws -> T? {
        return try typeConverter.convertFromWireType(obj: result, targetType: type)
    }
}
