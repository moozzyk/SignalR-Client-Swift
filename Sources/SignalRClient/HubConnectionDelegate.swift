//
//  HubConnectionDelegate.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

/**
 A protocol that allows receiving hub connection lifecycle event notifications.

 To receive hub connection lifecycle event notifications create a class that conforms to this protocol and register it using the `HubConnectionBuilder.withHubConnectionDelegate()` method.

 - note: The user is responsible for maintaining the reference to the delegate.
 */
public protocol HubConnectionDelegate: class {
    /**
     Invoked when the connection to the server opened successfully.

     - parameter hubConnection: the newly opened `HubConnection`
    */
    func connectionDidOpen(hubConnection: HubConnection)

    /**
     Invoked when the connection to the server failed to open.

     - parameter error: contains failure details
    */
    func connectionDidFailToOpen(error: Error)

    /**
     Invoked when the connection to the server was closed.

     - parameter error: If the connection was closed cleanly `nil`. Otherwise contains failure detais
    */
    func connectionDidClose(error: Error?)

    /**
     Invoked when the connection will try to reconnect.

     - parameter error: Contains the reason for reconnect
    */
    func connectionWillReconnect(error: Error)

    /**
     Invoked when the connection reconnected successfully.
    */
    func connectionDidReconnect()
}

public extension HubConnectionDelegate {
    func connectionWillReconnect(error: Error) {}
    func connectionDidReconnect() {}
}
