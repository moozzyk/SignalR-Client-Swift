//
//  Transport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol Transport: AnyObject {
    var delegate: TransportDelegate? {get set}
    var inherentKeepAlive: Bool {get}
    func start(url:URL, options: HttpConnectionOptions) -> Void
    func send(data: Data, sendDidComplete: @escaping (_ error:Error?) -> Void)
    func close() -> Void
}

internal protocol TransportFactory {
    func createTransport(availableTransports: [TransportDescription]) throws -> Transport
}
