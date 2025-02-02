//
//  InvocationHandler.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/4/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

internal protocol ServerInvocationHandler {
    var method: String { get }
    var arguments: [Encodable] { get }
    func createInvocationMessage(invocationId: String) -> HubMessage
    func startStreams()
    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error?
    func processCompletion(completionMessage: CompletionMessage)
    func raiseError(error: Error)
}

internal class InvocationHandler<T: Decodable>: ServerInvocationHandler {
    private let logger: Logger
    public private(set) var method: String
    public private(set) var arguments: [Encodable]
    private let clientStreamWorkers: [ClientStreamWorker]
    private let invocationDidComplete: (T?, Error?) -> Void

    init(
        logger: Logger, callbackQueue: DispatchQueue, method: String, arguments: [Encodable],
        clientStreamWorkers: [ClientStreamWorker],
        invocationDidComplete: @escaping (T?, Error?) -> Void
    ) {
        self.logger = logger
        self.method = method
        self.arguments = arguments
        self.clientStreamWorkers = clientStreamWorkers
        self.invocationDidComplete = { result, error in
            callbackQueue.async {
                clientStreamWorkers.forEach { $0.stop() }
                invocationDidComplete(result, error)
            }
        }
    }

    func createInvocationMessage(invocationId: String) -> HubMessage {
        let streamIds = clientStreamWorkers.map { $0.streamId }
        logger.log(
            logLevel: .debug,
            message:
                "Creating invocation message for method: '\(method)', invocationId: \(invocationId), streamIds: \(streamIds)"
        )
        return ServerInvocationMessage(
            invocationId: invocationId, target: method, arguments: arguments, streamIds: streamIds)
    }

    func startStreams() {
        clientStreamWorkers.forEach { $0.start() }
    }

    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error? {
        logger.log(logLevel: .error, message: "Stream item message received for non-streaming server side method")
        return SignalRError.protocolViolation(
            underlyingError: SignalRError.invalidOperation(
                message: "Stream item message received for non-streaming server side method"))
    }

    func processCompletion(completionMessage: CompletionMessage) {
        let invocationId = completionMessage.invocationId
        logger.log(logLevel: .debug, message: "Processing completion of method with invocationId: \(invocationId)")

        if let hubInvocationError = completionMessage.error {
            logger.log(
                logLevel: .error,
                message: "Server method with invocationId \(invocationId) failed with: \(hubInvocationError)")
            invocationDidComplete(nil, SignalRError.hubInvocationError(message: hubInvocationError))
            return
        }

        if !completionMessage.hasResult {
            logger.log(
                logLevel: .debug, message: "Void server method with invocationId \(invocationId) completed successfully"
            )
            invocationDidComplete(nil, nil)
            return
        }

        do {
            logger.log(
                logLevel: .debug, message: "Server method with invocationId \(invocationId) completed successfully")
            let result = try completionMessage.getResult(T.self)
            invocationDidComplete(result, nil)
        } catch {
            logger.log(
                logLevel: .error,
                message: "Error while getting result for server method with invocationId \(invocationId)")
            invocationDidComplete(nil, error)
        }
    }

    func raiseError(error: Error) {
        invocationDidComplete(nil, error)
    }
}

internal class StreamInvocationHandler<T: Decodable>: ServerInvocationHandler {
    private let logger: Logger
    public private(set) var method: String
    public private(set) var arguments: [Encodable]
    private let clientStreamWorkers: [ClientStreamWorker]
    private let streamItemReceived: (T) -> Void
    private let invocationDidComplete: (Error?) -> Void

    init(
        logger: Logger, callbackQueue: DispatchQueue, method: String, arguments: [Encodable],
        clientStreamWorkers: [ClientStreamWorker],
        streamItemReceived: @escaping (T) -> Void, invocationDidComplete: @escaping (Error?) -> Void
    ) {
        self.logger = logger
        self.method = method
        self.arguments = arguments
        self.clientStreamWorkers = clientStreamWorkers
        self.streamItemReceived = { item in callbackQueue.async { streamItemReceived(item) } }
        self.invocationDidComplete = { error in
            callbackQueue.async {
                clientStreamWorkers.forEach { $0.stop() }
                invocationDidComplete(error)
            }
        }
    }

    func createInvocationMessage(invocationId: String) -> HubMessage {
        let streamIds = clientStreamWorkers.map { $0.streamId }
        logger.log(
            logLevel: .debug,
            message:
                "Creating invocation message for streaming method: '\(method)', invocationId: \(invocationId), streamIds: \(streamIds)"
        )
        return StreamInvocationMessage(
            invocationId: invocationId, target: method, arguments: arguments, streamIds: streamIds)
    }

    func startStreams() {
        clientStreamWorkers.forEach { $0.start() }
    }

    func processStreamItem(streamItemMessage: StreamItemMessage) -> Error? {
        let invocationId = streamItemMessage.invocationId
        logger.log(
            logLevel: .debug,
            message: "Received stream item message for streaming method with invocationId: '\(invocationId)'")
        do {
            let value = try streamItemMessage.getItem(T.self)
            streamItemReceived(value)
            return nil
        } catch {
            logger.log(
                logLevel: .error,
                message: "Error while getting stream item value for method with invocationId: '\(invocationId)'")
            return error
        }
    }

    func processCompletion(completionMessage: CompletionMessage) {
        let invocationId = completionMessage.invocationId
        if let invocationError = completionMessage.error {
            logger.log(
                logLevel: .error,
                message: "Streaming server method with invocationId \(invocationId) failed with: \(invocationError)")
            invocationDidComplete(SignalRError.hubInvocationError(message: invocationError))
        } else {
            logger.log(
                logLevel: .debug,
                message: "Streaming server method with invocationId \(invocationId) completed successfully")
            invocationDidComplete(nil)
        }
    }

    func raiseError(error: Error) {
        invocationDidComplete(error)
    }
}
