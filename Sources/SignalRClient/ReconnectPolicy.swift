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
    public init() {}
    public func nextAttemptInterval(retryContext: RetryContext) -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}

internal class NoReconnectPolicy: ReconnectPolicy {
    func nextAttemptInterval(retryContext: RetryContext) -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}
