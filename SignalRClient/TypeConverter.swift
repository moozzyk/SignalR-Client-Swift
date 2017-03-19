//
//  TypeConverter.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/17/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol TypeConverter {
    func convertToWireType(obj: Any?) throws -> Any?
    func convertFromWireType<T>(obj:Any?, targetType: T.Type) throws -> T?
}
