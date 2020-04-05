//
//  ReconnectPolicy.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import Foundation

/**
 Contains information about the current reconnection attempt
 */
public struct RetryContext {
    /// The number on unsuccesful connect attempts for this reconnect
    let failedAttemptsCount: Int
    /// The time this reconnect started
    let reconnectStartTime: Date
    /// The original error that triggered this reconnect
    let error: Error
}

/**
 The ReconnectPolicy protocol allows implementing custom reconnect rules
 */
public protocol ReconnectPolicy {
    /**
     Returns the time interval when the next connect attempt should take place.
    - parameter retryContext: information about the current reconnection attempt
    - returns: time interval when the next connect attempt should take place. Returning `.never` indicates that no further connect attemps should take place.
     */
    func nextAttemptInterval(retryContext: RetryContext) -> DispatchTimeInterval
}

/**
 The default reconnect policy that allows providing custom intervals for connect attempts.
 */
public class DefaultReconnectPolicy: ReconnectPolicy {
    let retryIntervals: [DispatchTimeInterval]

    /*
     Initializes a new `DefaultReconnectPolicy` with the provided retry time intervals.
     - parameter retryIntervals: an array of retry intervals. If not provided the following intervals will be used 0, 2, 10 and 30 seconds.
     - note: when providing own `retryIntervals` the client will attempt to re-establish the connection at most as many times as the number of provided intervals. If this fails the connection will be stopped.
     */
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
