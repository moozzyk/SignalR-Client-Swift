//
//  ReactiveConnectionFailure.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 13/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ReactiveConnectionFailure: Error, Equatable {
    case failedToOpen(Error)
    case stoppedWithError(Error)
    case closedWithError(Error)
}

extension ReactiveConnectionFailure {
    public static func == (lhs: ReactiveConnectionFailure, rhs: ReactiveConnectionFailure) -> Bool {
        switch (lhs, rhs) {
        case let (.failedToOpen(e1), .failedToOpen(e2)):
            return e1 as NSError == e2 as NSError
        case let (.stoppedWithError(e1), .stoppedWithError(e2)):
            return e1 as NSError == e2 as NSError
        case let (.closedWithError(e1), .closedWithError(e2)):
            return e1 as NSError == e2 as NSError
        default:
            return false
        }
    }
}
