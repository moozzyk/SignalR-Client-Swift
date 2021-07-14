//
//  ReactiveHubConnectionFailure.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ReactiveHubConnectionFailure: Error, Equatable {
    case failedToOpen(Error)
    case closedWithError(Error)
}

extension ReactiveHubConnectionFailure {
    public static func == (lhs: ReactiveHubConnectionFailure, rhs: ReactiveHubConnectionFailure) -> Bool {
        switch (lhs, rhs) {
        case let (.failedToOpen(e1), .failedToOpen(e2)):
            return e1 as NSError == e2 as NSError
        case let (.closedWithError(e1), .closedWithError(e2)):
            return e1 as NSError == e2 as NSError
        default:
            return false
        }
    }
}
