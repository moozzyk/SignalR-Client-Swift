//
//  ReactiveHubStreamFailure.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ReactiveHubStreamFailure: Error, Equatable {
    case streamCompletedWithError(Error)
}

extension ReactiveHubStreamFailure {
    public static func == (lhs: ReactiveHubStreamFailure, rhs: ReactiveHubStreamFailure) -> Bool {
        switch (lhs, rhs) {
        case let (.streamCompletedWithError(e1), .streamCompletedWithError(e2)):
            return e1 as NSError == e2 as NSError
        }
    }
}
