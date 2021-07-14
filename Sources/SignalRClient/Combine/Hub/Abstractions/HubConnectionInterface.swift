//
//  HubConnectionInterface.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol HubConnectionProtocol: AnyObject {
    var delegate: HubConnectionDelegate? { get set }
    var connectionId: String? { get }
    func start()
    func on(method: String, callback: @escaping (_ argumentExtractor: ArgumentExtractor) throws -> Void)
    func send(method: String, arguments:[Encodable], sendDidComplete: @escaping (_ error: Error?) -> Void)
    func invoke(method: String, arguments: [Encodable], invocationDidComplete: @escaping (_ error: Error?) -> Void)
    func invoke<T: Decodable>(method: String, arguments: [Encodable], resultType: T.Type, invocationDidComplete: @escaping (_ result: T?, _ error: Error?) -> Void)
    func stream<T: Decodable>(method: String, arguments: [Encodable], streamItemReceived: @escaping (_ item: T) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle
    func cancelStreamInvocation(streamHandle: StreamHandle, cancelDidFail: @escaping (_ error: Error) -> Void)
    func stop()
}

extension HubConnection: HubConnectionProtocol {}

