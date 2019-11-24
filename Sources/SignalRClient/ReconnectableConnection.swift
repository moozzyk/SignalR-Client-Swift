//
//  ReconnectableConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 11/17/19.
//

import Foundation

internal class ReconnectableConnection: Connection {
    private let connectionFactory: () -> Connection
    private let reconnectPolicy: ReconnectPolicy
    private var underlyingConnection: Connection
    private var wrappedDelegate: ConnectionDelegate?

    var delegate: ConnectionDelegate?
    var connectionId: String? {
        return underlyingConnection.connectionId
    }

    init(connectionFactory: @escaping () -> Connection, reconnectPolicy: ReconnectPolicy) {
        self.connectionFactory = connectionFactory
        self.reconnectPolicy = reconnectPolicy
        self.underlyingConnection = connectionFactory()
    }

    func start() {
        wrappedDelegate = ReconnectableConnectionDelegate(connectionDelegate: delegate)
        underlyingConnection.delegate = wrappedDelegate
        underlyingConnection.start()
    }

    func send(data: Data, sendDidComplete: (Error?) -> Void) {
        underlyingConnection.send(data: data, sendDidComplete: sendDidComplete)
    }

    func stop(stopError: Error?) {
        underlyingConnection.stop(stopError: stopError)
    }
}

fileprivate class ReconnectableConnectionDelegate: ConnectionDelegate {
    private let connectionDelegate: ConnectionDelegate?

    init(connectionDelegate: ConnectionDelegate?) {
        self.connectionDelegate = connectionDelegate
    }

    func connectionDidOpen(connection: Connection) {
        connectionDelegate?.connectionDidOpen(connection: connection)
    }

    func connectionDidFailToOpen(error: Error) {
        connectionDelegate?.connectionDidFailToOpen(error: error)
    }

    func connectionDidReceiveData(connection: Connection, data: Data) {
        connectionDelegate?.connectionDidReceiveData(connection: connection, data: data)
    }

    func connectionDidClose(error: Error?) {
        connectionDelegate?.connectionDidClose(error: error)
    }
}
