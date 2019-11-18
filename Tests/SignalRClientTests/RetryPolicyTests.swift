//
//  RetryPolicyTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import XCTest
@testable import SignalRClient

class RetryPolicyTest: XCTestCase {
    public func testThatNoRetryPolicyReturnsDispatchTimeInternalNever() {
        XCTAssertEqual(DispatchTimeInterval.never, NoRetryPolicy().nextRetryInterval())
    }
}
