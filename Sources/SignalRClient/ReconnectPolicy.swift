//
//  ReconnectPolicy.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import Foundation

public protocol ReconnectPolicy {
    func nextAttemptInterval() -> DispatchTimeInterval
}

public class DefaultReconnectPolicy: ReconnectPolicy {
    public init() {}
    public func nextAttemptInterval() -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}

internal class NoReconnectPolicy: ReconnectPolicy {
    func nextAttemptInterval() -> DispatchTimeInterval {
        return DispatchTimeInterval.never
    }
}
