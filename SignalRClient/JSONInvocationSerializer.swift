//
//  JSONInvocationSerializer.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/6/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

class JSONInvocationSerializer {
    func writeInvocationDescriptor(invocationDescriptor: InvocationDescriptor) -> Data {
        // TODO: figure out how to write JSON correctly

        let argString = serializeArguments(arguments: invocationDescriptor.arguments)
        let payload =
            "{ \"Id\": \(invocationDescriptor.id), \"Method\": \"\(invocationDescriptor.method)\", \"Arguments\": [\(argString)] }"

        return payload.data(using: .utf8)!
    }

    private func serializeArguments(arguments: [Any?]) -> String {

        var argString = ""

        for arg in arguments {
            if arg == nil {
                argString += "null"
            }
            else if arg is String {
                argString += "\"\(arg!)\""
            }

            // argumentString += ", "
        }

        return argString
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
