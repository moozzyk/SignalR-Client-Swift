//
//  HubConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HubConnection {

    private let connection: SocketConnection!

    public convenience init(url: URL) {
        self.init(connection: Connection(url: url))
    }

    public init(connection: SocketConnection!) {
        self.connection = connection
    }

    public func start() {

    }

    public func invoke(functionName: String) throws -> Void {

    }

    public func invoke<T>(functionName: String) throws -> T {
        // not implemented for now
        throw NSError()
    }

    public func stop() {

    }
}
