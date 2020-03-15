//
//  ReconnectPolicyTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import XCTest
@testable import SignalRClient

class ReconnectPolicyTests: XCTestCase {
    public func testThatNoReconnectPolicyReturnsDispatchTimeInternalNever() {
        for attempts in 0...5 {
            let retryContext = createRetryContext(failedAttemptsCount: attempts)
            XCTAssertEqual(.never, NoReconnectPolicy().nextAttemptInterval(retryContext: retryContext))
        }
    }

    public func testDefaultReconnectPolicyReturnsDefaultIntervals() {
        XCTAssertEqual(.milliseconds(0), DefaultReconnectPolicy().nextAttemptInterval(retryContext: createRetryContext(failedAttemptsCount: 0)))
        XCTAssertEqual(.seconds(2), DefaultReconnectPolicy().nextAttemptInterval(retryContext: createRetryContext(failedAttemptsCount: 1)))
        XCTAssertEqual(.seconds(10), DefaultReconnectPolicy().nextAttemptInterval(retryContext: createRetryContext(failedAttemptsCount: 2)))
        XCTAssertEqual(.seconds(30), DefaultReconnectPolicy().nextAttemptInterval(retryContext: createRetryContext(failedAttemptsCount: 3)))
        XCTAssertEqual(.never, DefaultReconnectPolicy().nextAttemptInterval(retryContext: createRetryContext(failedAttemptsCount: 4)))
        XCTAssertEqual(.never, DefaultReconnectPolicy().nextAttemptInterval(retryContext: createRetryContext(failedAttemptsCount: 42)))
    }

    private func createRetryContext(failedAttemptsCount: Int) -> RetryContext {
        return RetryContext(failedAttemptsCount: failedAttemptsCount, reconnectStartTime: Date(), error: SignalRError.invalidOperation(message: "blah"))
    }
}
