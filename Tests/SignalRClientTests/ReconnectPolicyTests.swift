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
        XCTAssertEqual(DispatchTimeInterval.never, NoReconnectPolicy().nextAttemptInterval())
    }
}
