//
//  InvocationDescriptor.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/6/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

class InvocationDescriptor {
    let id: Int
    let method: String
    let arguments: [Any?]

    init(id: Int, method: String, arguments: [Any?]) {
        self.id = id
        self.method = method
        self.arguments = arguments
    }
}

protocol InvocationResult {
    var id: Int { get }
    var error: String? { get }
    func getResult<T>(type: T.Type) throws -> T?
}
