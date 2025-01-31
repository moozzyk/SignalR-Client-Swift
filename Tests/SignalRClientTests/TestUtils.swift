//
//  TestUtils.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 1/30/25.
//

import Foundation

func createAsyncStream(items: [Encodable], sleepMs: UInt64) -> AsyncStream<Encodable> {
    return AsyncStream { continuation in
        Task {
            for i in items {
                continuation.yield(i)
                try? await Task.sleep(nanoseconds: sleepMs * 1_000_000)
            }
            continuation.finish()
        }
    }
}

struct MessageSHA: Decodable {
    let value: String
    let shaType: Int
}
