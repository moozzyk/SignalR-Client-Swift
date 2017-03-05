//
//  HubConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HubConnection {

    private var connection: SocketConnection!

    public weak var delegate: HubConnectionDelegate!
    private var socketConnectionDelegate: HubSocketConnectionDelegate?

    public convenience init(url: URL) {
        self.init(connection: Connection(url: url))
    }

    public init(connection: SocketConnection!) {
        self.connection = connection
        socketConnectionDelegate = HubSocketConnectionDelegate(hubConnection: self)
        self.connection.delegate = socketConnectionDelegate
    }

    public func start() {
        connection.start()
    }

    public func stop() {
        connection.stop()
    }

    public func invoke(functionName: String) throws -> Void {

    }

    public func invoke<T>(functionName: String) throws -> T {
        // not implemented for now
        throw NSError()
    }

    fileprivate func hubConnectionDidReceiveData(/*needed? connection: SocketConnection!,*/ data: Data) {

    }
}

public class HubSocketConnectionDelegate : SocketConnectionDelegate {
    private weak var hubConnection: HubConnection?

    fileprivate init(hubConnection: HubConnection!) {
        self.hubConnection = hubConnection
    }

    public func connectionDidOpen(connection: SocketConnection!) {
        hubConnection?.delegate.connectionDidOpen(hubConnection: hubConnection!)
    }

    public func connectionDidFailToOpen(error: Error) {
        hubConnection?.delegate.connectionDidFailToOpen(error: error)
    }

    public func connectionDidReceiveData(connection: SocketConnection!, data: Data) {
        hubConnection?.hubConnectionDidReceiveData(data: data)
    }

    public func connectionDidClose(error: Error?) {
        hubConnection?.delegate.connectionDidClose(error: error)
    }
}

