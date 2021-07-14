//
//  ReactiveConnection.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 13/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Combine
import Foundation

@available(iOS 13.0, macOS 10.15, *)
public protocol ReactiveConnection: AnyObject {
    var connectionId: String? { get }
    var publisher: AnyPublisher<ReactiveConnectionEvent, ReactiveConnectionFailure> { get }
    func start()
    func send(data: Data)
    func stop(withError error: Error?)
}

@available(iOS 13.0, macOS 10.15, *)
public extension ReactiveConnection {
    func stop() { stop(withError: nil) }
}
