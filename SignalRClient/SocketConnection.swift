//
//  SocketConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol SocketConnection {
    var delegate: SocketConnectionDelegate! {get set}
    func start(transport: Transport?) -> Void
    func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) -> Void
    func stop() -> Void
}
