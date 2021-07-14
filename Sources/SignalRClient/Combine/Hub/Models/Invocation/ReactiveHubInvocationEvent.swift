//
//  ReactiveHubInvocationEvent.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public typealias InvocationItem = WrappedDecodable

public enum ReactiveHubInvocationEvent: Equatable {
    case itemReceived(InvocationItem?, fromMethod: String, withArguments: [Encodable])
    case invocationCompleted(forMethod: String, withArguments: [Encodable])
    case cancelationFailed(forHandle: StreamHandle, withError: Error)
}

extension ReactiveHubInvocationEvent {
    public static func == (lhs: ReactiveHubInvocationEvent, rhs: ReactiveHubInvocationEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.itemReceived(i1, m1, args1), .itemReceived(i2, m2, args2)):
            return i1 == i2 && m1 == m2 && args1.asJSON() == args2.asJSON()
        case let (.invocationCompleted(m1, args1), .invocationCompleted(m2, args2)):
            return m1 == m2 && args1.asJSON() == args2.asJSON()
        case let (.cancelationFailed(h1, e1), .cancelationFailed(h2, e2)):
            return h1.invocationId == h2.invocationId && e1 as NSError == e2 as NSError
        default:
            return false
        }
    }
}
