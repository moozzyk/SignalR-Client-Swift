//
//  InvocationHandler.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/4/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

internal protocol ServerInvocationHandler {
    func processMessage(message: HubMessage?, error: Error?)
}

internal class InvocationHandler<T>: ServerInvocationHandler {
    private let typeConverter: TypeConverter
    private let invocationDidComplete: (T?, Error?) -> Void

    init(typeConverter: TypeConverter, invocationDidComplete: @escaping (T?, Error?) -> Void) {
        self.typeConverter = typeConverter
        self.invocationDidComplete = invocationDidComplete
    }

    func processMessage(message: HubMessage?, error: Error?) {
        if error != nil {
            invocationDidComplete(nil, error!)
            return
        }

        guard let completionMessage = message as? CompletionMessage else {
            invocationDidComplete(nil, SignalRError.protocolViolation)
            return
        }

        if let hubInvocationError = completionMessage.error {
            invocationDidComplete(nil, SignalRError.hubInvocationError(message: hubInvocationError))
            return
        }

        if !completionMessage.hasResult {
            invocationDidComplete(nil, nil)
            return
        }

        do {
            let result = try typeConverter.convertFromWireType(obj: completionMessage.result, targetType: T.self)
            invocationDidComplete(result, nil)
        } catch {
            invocationDidComplete(nil, error)
        }
    }
}
