//
//  InvocationHandler.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/4/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

internal protocol ServerInvocationHandler {
    func createInvocationMessage(invocationId: String, method: String, arguments: [Any?]) -> HubMessage
    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error?
    func processCompletion(completionMessage: CompletionMessage)
    func raiseError(error: Error)
}

internal class InvocationHandler<T>: ServerInvocationHandler {
    private let typeConverter: TypeConverter
    private let invocationDidComplete: (T?, Error?) -> Void

    init(typeConverter: TypeConverter, invocationDidComplete: @escaping (T?, Error?) -> Void) {
        self.typeConverter = typeConverter
        self.invocationDidComplete = invocationDidComplete
    }

    func createInvocationMessage(invocationId: String, method: String, arguments: [Any?]) -> HubMessage {
        return InvocationMessage(invocationId: invocationId, target: method, arguments: arguments)
    }

    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error? {
        return SignalRError.protocolViolation;
    }

    func processCompletion(completionMessage: CompletionMessage) {
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

    func raiseError(error: Error) {
        invocationDidComplete(nil, error)
    }
}

internal class StreamInvocationHandler<T>: ServerInvocationHandler {
    private let typeConverter: TypeConverter
    private let streamItemReceived: (T?) -> Void
    private let invocationDidComplete: (Error?) -> Void

    init(typeConverter: TypeConverter, streamItemReceived: @escaping (T?) -> Void, invocationDidComplete: @escaping (Error?) -> Void) {
        self.typeConverter = typeConverter
        self.streamItemReceived = streamItemReceived
        self.invocationDidComplete = invocationDidComplete
    }

    func createInvocationMessage(invocationId: String, method: String, arguments: [Any?]) -> HubMessage {
        return StreamInvocationMessage(invocationId: invocationId, target: method, arguments: arguments)
    }

    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error? {
        do {
            let value = try typeConverter.convertFromWireType(obj: streamItemMessage.item, targetType: T.self)
            streamItemReceived(value)
            return nil
        } catch {
            return error
        }
    }

    func processCompletion(completionMessage: CompletionMessage) {
        if let invocationError = completionMessage.error {
            invocationDidComplete(SignalRError.hubInvocationError(message: invocationError))
        } else {
            invocationDidComplete(nil)
        }
    }

    func raiseError(error: Error) {
        invocationDidComplete(error)
    }
}
