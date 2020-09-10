//
//  Connection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol Connection {
    var delegate: ConnectionDelegate? {get set}
    var connectionId: String? {get}
    func start() -> Void
    func send(data: Data, sendDidComplete: @escaping (_ error: Error?) -> Void) -> Void
    func stop(stopError: Error?) -> Void
}
