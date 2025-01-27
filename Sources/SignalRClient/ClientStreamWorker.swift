//
//  ClientStreamWorker.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 1/25/25.
//

import Foundation

internal protocol ClientStreamWorker {
    var streamId: String { get }
    func start()
    func stop()
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
internal class AsyncStreamClientStreamWorker: ClientStreamWorker {
    internal private(set) var streamId: String
    private let stream: AsyncStream<Encodable>
    private let hubProtocol: HubProtocol
    private let logger: Logger
    private var sendFn: (HubMessage) async throws -> Void
    private var streamTask: Task<Void, Error>?

    init(
        streamId: String, stream: AsyncStream<Encodable>, hubProtocol: HubProtocol,
        logger: Logger, sendFn: @escaping (HubMessage) async throws -> Void
    ) {
        self.streamId = streamId
        self.stream = stream
        self.hubProtocol = hubProtocol
        self.logger = logger
        self.sendFn = sendFn
    }

    func start() {
        logger.log(logLevel: .info, message: "Starting processing stream \(streamId)")
        guard streamTask == nil else {
            logger.log(logLevel: .error, message: "Internal error: incorrect attempt to start stream \(streamId)")
            return
        }
        streamTask = Task {
            for await value in stream {
                if Task.isCancelled {
                    logger.log(logLevel: .info, message: "Client Stream \(streamId) processing has been canceled")
                    break
                }

                do {
                    try await self.sendFn(StreamItemMessage(invocationId: streamId, item: value))
                } catch {
                    logger.log(
                        logLevel: .error,
                        message:
                            "Sending stream item failed. Exiting stream \(streamId) processing loop. Error \(error)")
                    break
                }
            }
            logger.log(
                logLevel: .debug, message: "Stream \(streamId) processing loop completed. Sending stream completion")
            do {
                try await sendFn(CompletionMessage(invocationId: streamId, error: nil))
            } catch {
                logger.log(
                    logLevel: .error,
                    message: "Sending stream item failed. Exiting stream processing loop. Error \(error)")
            }
            logger.log(logLevel: .debug, message: "Leaving stream \(streamId) task")
        }
    }

    func stop() {
        logger.log(logLevel: .info, message: "Canceling stream \(streamId) processing")
        streamTask?.cancel()
    }
}
