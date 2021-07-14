//
//  ReactiveHubConnection.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Combine
import Foundation

@available(iOS 13.0, macOS 10.15, *)
public protocol ReactiveHubConnection: AnyObject {
    var connectionId: String? { get }
    var connectionPublisher: AnyPublisher<ReactiveHubConnectionEvent, ReactiveHubConnectionFailure> { get }
    var invocationPublisher: AnyPublisher<ReactiveHubInvocationEvent, ReactiveHubInvocationFailure> { get }
    func start()
    func on(method: String)
    func send(method: String, arguments:[Encodable])
    func invoke(method: String, arguments: [Encodable])
    func invoke<T: Decodable>(method: String, arguments: [Encodable], resultType: T.Type)
    func stream<T: Decodable>(method: String, arguments: [Encodable], streamResultType: T.Type) -> StreamHandle
    func cancelStreamInvocation(streamHandle: StreamHandle)
    func stop()
}

//@frozen public struct AnyDecodable: Decodable {
//    private var value: Decodable
//    public var value: Any { _value }
//
//    public init<T: Decodable>(_ value: T) {
//        self._value = value
//    }
//}
