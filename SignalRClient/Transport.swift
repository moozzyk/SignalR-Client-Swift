//
//  Transport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol Transport: class {
    var delegate: TransportDelegate! {get set}
    func start(url:URL, headers: [String: String]) -> Void
    func send(data: Data, sendDidComplete: (_ error:Error?) -> Void)
    func close() -> Void
}
