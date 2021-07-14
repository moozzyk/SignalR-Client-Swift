//
//  DecodableWrapper.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public struct WrappedDecodable: Equatable {
    public let wrappedValue: Any
    private let isEqual: (WrappedDecodable) -> Bool

    public init<T: Decodable>(_ value: T) {
        self.wrappedValue = value
        isEqual = { otherWrappedDecodable in
            guard let other = otherWrappedDecodable.wrappedValue as? T else { return false }
            guard value is AnyHashable else { return false }
            guard other is AnyHashable else { return false }
            return other as? AnyHashable == value as? AnyHashable
        }
    }

    public func decoded<T: Decodable>(as: T.Type) -> T? {
        self.wrappedValue as? T
    }

    public static func == (lhs: WrappedDecodable, rhs: WrappedDecodable) -> Bool {
        lhs.isEqual(rhs)
    }
}
