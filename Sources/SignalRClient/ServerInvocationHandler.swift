//
//  InvocationHandler.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/4/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

internal protocol ServerInvocationHandler {
    func createInvocationMessage(invocationId: String, method: String, arguments: [Encodable]) -> HubMessage
    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error?
    func processCompletion(completionMessage: CompletionMessage)
    func raiseError(error: Error)
}

internal class InvocationHandler<T: Decodable>: ServerInvocationHandler {
    private let logger: Logger
    private let invocationDidComplete: (T?, Error?) -> Void

    init(logger: Logger, invocationDidComplete: @escaping (T?, Error?) -> Void) {
        self.logger = logger
        self.invocationDidComplete = invocationDidComplete
    }

    func createInvocationMessage(invocationId: String, method: String, arguments: [Encodable]) -> HubMessage {
        logger.log(logLevel: .debug, message: "Creating invocation message for method: '\(method)', invocationId: \(invocationId)")
        return ServerInvocationMessage(invocationId: invocationId, target: method, arguments: arguments)
    }

    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error? {
        logger.log(logLevel: .error, message: "Stream item message received for non-streaming server side method")
        return SignalRError.protocolViolation(underlyingError: SignalRError.invalidOperation(message: "Stream item message received for non-streaming server side method"))
    }

    func processCompletion(completionMessage: CompletionMessage) {
        let invocationId = completionMessage.invocationId
        logger.log(logLevel: .debug, message: "Processing completion of method with invocationId: \(invocationId)")

        if let hubInvocationError = completionMessage.error {
            logger.log(logLevel: .error, message: "Server method with invocationId \(invocationId) failed with: \(hubInvocationError)")
            invocationDidComplete(nil, SignalRError.hubInvocationError(message: hubInvocationError))
            return
        }

        if !completionMessage.hasResult {
            logger.log(logLevel: .debug, message: "Void server method with invocationId \(invocationId) completed successfully")
            invocationDidComplete(nil, nil)
            return
        }

        do {
            logger.log(logLevel: .debug, message: "Server method with invocationId \(invocationId) completed successfully")
            let result = try completionMessage.getResult(T.self)
            invocationDidComplete(result, nil)
        } catch {
            logger.log(logLevel: .error, message: "Error while getting result for server method with invocationId \(invocationId)")
            invocationDidComplete(nil, error)
        }
    }

    func raiseError(error: Error) {
        invocationDidComplete(nil, error)
    }
}

internal class StreamInvocationHandler<T: Decodable>: ServerInvocationHandler {
    private let logger: Logger
    private let streamItemReceived: (T) -> Void
    private let invocationDidComplete: (Error?) -> Void

    init(logger: Logger, streamItemReceived: @escaping (T) -> Void, invocationDidComplete: @escaping (Error?) -> Void) {
        self.logger = logger
        self.streamItemReceived = streamItemReceived
        self.invocationDidComplete = invocationDidComplete
    }

    func createInvocationMessage(invocationId: String, method: String, arguments: [Encodable]) -> HubMessage {
        logger.log(logLevel: .debug, message: "Creating invocation message for streaming method: '\(method)', invocationId: \(invocationId)")
        return StreamInvocationMessage(invocationId: invocationId, target: method, arguments: arguments)
    }

    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error? {
        let invocationId = streamItemMessage.invocationId
        logger.log(logLevel: .debug, message: "Received stream item message for streaming method with invocationId: '\(invocationId)'")
        do {
            let value = try streamItemMessage.getItem(T.self)
            streamItemReceived(value)
            return nil
        } catch {
            logger.log(logLevel: .error, message: "Error while getting stream item value for method with invocationId: '\(invocationId)'")
            return error
        }
    }

    func processCompletion(completionMessage: CompletionMessage) {
        let invocationId = completionMessage.invocationId
        if let invocationError = completionMessage.error {
            logger.log(logLevel: .error, message: "Streaming server method with invocationId \(invocationId) failed with: \(invocationError)")
            invocationDidComplete(SignalRError.hubInvocationError(message: invocationError))
        } else {
            logger.log(logLevel: .debug, message: "Streaming server method with invocationId \(invocationId) completed successfully")
            invocationDidComplete(nil)
        }
    }

    func raiseError(error: Error) {
        invocationDidComplete(error)
    }
}
