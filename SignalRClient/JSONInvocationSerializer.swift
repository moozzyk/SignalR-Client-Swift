//
//  JSONInvocationSerializer.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/6/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

class JSONInvocationSerializer {
    func writeInvocationDescriptor(invocationDescriptor: InvocationDescriptor) throws -> Data {
        let payload: [String: Any] = [
            "Id": invocationDescriptor.id,
            "Method": invocationDescriptor.method,
            // TODO custom type resolver
            "Arguments": invocationDescriptor.arguments
        ];

        return try JSONSerialization.data(withJSONObject: payload)
    }

    func processIncomingData(data: Data) throws -> AnyObject {
        let json = try JSONSerialization.jsonObject(with: data)
        if let message = json as? NSDictionary {
            if message.object(forKey: "Result") != nil {
                let id = message.object(forKey: "Id")
                let error = message.object(forKey: "Error")
                let result = message.object(forKey: "Result")
                return JSONInvocationResult(id: Int(id as! String)!, error: error as? String, result: result as AnyObject?)
            }
        }

        throw SignalRError.unexpectedMessage
    }
}

fileprivate class JSONInvocationResult: InvocationResult {
    let id: Int
    let error: String?
    let result: AnyObject?

    init(id: Int, error: String?, result: AnyObject?) {
        self.id = id
        self.error = error
        self.result = result
    }

    func getResult<T>(type: T.Type) -> T? {
        // TODO custom type resolver

        if result == nil {
            return nil
        }

        if type == String.self {
            return result as! T?
        }

        // TODO throw
        return nil;
    }
}
