//
//  ClientStreamWorkerTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 1/28/25.
//

import XCTest

@testable import SignalRClient

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class ClientStreamWorkerTests: XCTestCase {
    func testClientStreamWorkerSendsDataAndCompletion() async {
        let items = Array(1...5)
        let stream = createAsyncStream(items: items, sleepMs: 0)
        let logger = PrintLogger()
        let jsonHubProtocol = JSONHubProtocol(logger: logger)
        var sentMessages: [HubMessage] = []
        let worker = AsyncStreamClientStreamWorker(
            streamId: "1", stream: stream, hubProtocol: jsonHubProtocol, logger: logger,
            sendFn: { message in sentMessages.append(message) })
        worker.start()
        try? await Task.sleep(nanoseconds: 10 * 1_000_000)
        XCTAssertEqual(sentMessages.count, 6)
        XCTAssertTrue(sentMessages.dropLast().allSatisfy { $0 is StreamItemMessage })
        XCTAssertEqual(items, sentMessages.dropLast().map {($0 as! StreamItemMessage).item! as! Int})
        XCTAssertTrue(sentMessages.last is CompletionMessage)
    }

    func testClientStreamWorkerSendsCompletionIfSendingStreamItemFails() async {
        let items = [1, 1, 3, 1, 1]
        let stream = createAsyncStream(items: items, sleepMs: 0)
        let logger = PrintLogger()
        let jsonHubProtocol = JSONHubProtocol(logger: logger)
        var sentMessages: [HubMessage] = []
        let worker = AsyncStreamClientStreamWorker(
            streamId: "1", stream: stream, hubProtocol: jsonHubProtocol, logger: logger,
            sendFn: { message in
                if let message = message as? StreamItemMessage, let item = message.item as? Int, item == 3 {
                    throw NSError(domain: "Not supported", code: -1)
                }
                sentMessages.append(message) })
        worker.start()
        try? await Task.sleep(nanoseconds: 10 * 1_000_000)
        XCTAssertEqual(sentMessages.count, 3)
        XCTAssertTrue(sentMessages.dropLast().allSatisfy { ($0 as! StreamItemMessage).item as! Int == 1})
        XCTAssertTrue(sentMessages.last is CompletionMessage)
    }

    func testClientStreamWorkerIgnoresErrorsWhenSendingStreamCompletion() async throws {
        let items = [1, 1, 1, 1, 1]
        let stream = createAsyncStream(items: items, sleepMs: 0)
        let logger = PrintLogger()
        let jsonHubProtocol = JSONHubProtocol(logger: logger)
        var sentMessages: [HubMessage] = []
        let worker = AsyncStreamClientStreamWorker(
            streamId: "1", stream: stream, hubProtocol: jsonHubProtocol, logger: logger,
            sendFn: { message in
                if message is CompletionMessage {
                    throw NSError(domain: "Not supported", code: -1)
                }
                sentMessages.append(message) })
        worker.start()
        try? await Task.sleep(nanoseconds: 10 * 1_000_000)
        XCTAssertEqual(sentMessages.count, 5)
        XCTAssertTrue(sentMessages.allSatisfy { ($0 as! StreamItemMessage).item as! Int == 1})
    }

    func testClientStreamWorkerCancelsTasksAfterStop() async throws {
        let items = [1, 1, 1, 1, 1]
        let stream = createAsyncStream(items: items, sleepMs: 2)
        let logger = PrintLogger()
        let jsonHubProtocol = JSONHubProtocol(logger: logger)
        var sentMessages: [HubMessage] = []
        let worker = AsyncStreamClientStreamWorker(
            streamId: "1", stream: stream, hubProtocol: jsonHubProtocol, logger: logger,
            sendFn: { message in sentMessages.append(message) })
        worker.start()
        try? await Task.sleep(nanoseconds: 5 * 1_000_000)
        worker.stop()
        try? await Task.sleep(nanoseconds: 5 * 1_000_000)
        XCTAssertTrue(sentMessages.count > 2 && sentMessages.count < 5)
        XCTAssertTrue(sentMessages.last is CompletionMessage)
    }
}

/*
        let stream = AsyncStream<Encodable> { continuation in
            DispatchQueue.global().async {
                for i in 1...5 {
                    -                        continuation.yield([1, 2, 3, 4])
                    +                        continuation.yield(Data([UInt8(i)]).base64EncodedString())
                    +//                        continuation.yield([1, 2, 3, 4])
                }
                continuation.finish()
            }
        }
        let stream = AsyncStream(unfolding: {
            return Int.random(in: 0..<Int.max)
        })

        let stream2 = AsyncStream { cont in
            cont.yield(Int.random(in: 0..<Int.max))
        }

        lazy var stream: AsyncStream<CLLocation> = {
            AsyncStream { (continuation: AsyncStream<CLLocation>.Continuation) -> Void in
                self.continuation = continuation
            }
        }()
        var continuation: AsyncStream<CLLocation>.Continuation?

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            for location in locations {
                continuation?.yield(location)
            }
        }
*/
