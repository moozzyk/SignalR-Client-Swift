//
//  ReactiveHubInvocationFailure.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ReactiveHubInvocationFailure: Error, Equatable {
    case invokeCompletedWithError(Error)
}

extension ReactiveHubInvocationFailure {
    public static func == (lhs: ReactiveHubInvocationFailure, rhs: ReactiveHubInvocationFailure) -> Bool {
        switch (lhs, rhs) {
        case let (.invokeCompletedWithError(e1), .invokeCompletedWithError(e2)):
            return e1 as NSError == e2 as NSError
        }
    }
}
