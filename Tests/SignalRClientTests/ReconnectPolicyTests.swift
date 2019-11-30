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
            let retryContext = RetryContext(failedAttemptsCount: attempts, reconnectStartTime: Date(), error: SignalRError.invalidOperation(message: "blah"))
            XCTAssertEqual(DispatchTimeInterval.never, NoReconnectPolicy().nextAttemptInterval(retryContext: retryContext))
        }
    }
}
