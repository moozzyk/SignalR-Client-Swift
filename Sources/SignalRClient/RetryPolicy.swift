//
//  RetryPolicy.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import Foundation

public protocol RetryPolicy {
    func nextRetryInterval() -> DispatchTimeInterval
}

public class DefaultRetryPolicy: RetryPolicy {
    public init() {}
    public func nextRetryInterval() -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}

internal class NoRetryPolicy: RetryPolicy {
    func nextRetryInterval() -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}
