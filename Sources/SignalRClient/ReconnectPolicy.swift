//
//  ReconnectPolicy.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import Foundation

public struct RetryContext {
    let failedAttemptsCount: Int
    let reconnectStartTime: Date
    let error: Error
}

public protocol ReconnectPolicy {
    func nextAttemptInterval(retryContext: RetryContext) -> DispatchTimeInterval
}

public class DefaultReconnectPolicy: ReconnectPolicy {
    let retryIntervals: [DispatchTimeInterval]
    public init(retryIntervals: [DispatchTimeInterval] = [.milliseconds(0), .seconds(2), .seconds(10), .seconds(30)]) {
        self.retryIntervals = retryIntervals
    }

    public func nextAttemptInterval(retryContext: RetryContext) -> DispatchTimeInterval {
        if retryContext.failedAttemptsCount >= retryIntervals.count {
            return .never
        }
        return retryIntervals[retryContext.failedAttemptsCount]
    }
}

internal class NoReconnectPolicy: ReconnectPolicy {
    func nextAttemptInterval(retryContext: RetryContext) -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}
