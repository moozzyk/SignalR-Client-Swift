//
//  CombineHTTPConnection.swift
//  macOS SignalRClient
//
//  Created by Eduardo Bocato on 13/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, macOS 10.15, *)
public final class CombineHTTPConnection: ReactiveConnection {
    // MARK: - Dependencies

    private(set) var httpConnection: Connection

    // MARK: - Public Properties

    public var connectionId: String? { httpConnection.connectionId }
    public var publisher: AnyPublisher<ReactiveConnectionEvent, ReactiveConnectionFailure> {
        connectionSubject.removeDuplicates().eraseToAnyPublisher()
    }

    // MARK: - Internal Properties

    let connectionSubject: PassthroughSubject<ReactiveConnectionEvent, ReactiveConnectionFailure> = .init()


    // MARK: - Initialization

    public convenience init(
        url: URL,
        options: HttpConnectionOptions = HttpConnectionOptions(),
        logger: Logger = NullLogger()
    ) {
        self.init(
            url: url,
            options: options,
            transportFactory: DefaultTransportFactory(logger: logger),
            logger: logger
        )
    }

    init(
        url: URL,
        options: HttpConnectionOptions,
        transportFactory: TransportFactory,
        logger: Logger
    ) {
        self.httpConnection = HttpConnection(
            url: url,
            options: options,
            transportFactory: transportFactory,
            logger: logger
        )
        self.httpConnection.delegate = self
    }


    // MARK: Public API

    public func start() {
        httpConnection.start()
    }

    public func send(data: Data) {
        httpConnection.send(data: data) { [weak self] error in
            if let error = error {
                self?.connectionSubject.send(.failedToSendData(data, error))
            } else {
                self?.connectionSubject.send(.succesfullySentData(data))
            }
        }
    }

    public func stop(withError error: Error?) {
        httpConnection.stop(stopError: error)
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension CombineHTTPConnection: ConnectionDelegate {
    public func connectionDidOpen(connection: Connection) {
        connectionSubject.send(.opened(connection))
    }

    public func connectionDidFailToOpen(error: Error) {
        connectionSubject.send(completion: .failure(.failedToOpen(error)))
    }

    public func connectionDidReceiveData(connection: Connection, data: Data) {
        connectionSubject.send(.gotData(fromConnection: connection, data: data))
    }

    public func connectionDidClose(error: Error?) {
        if let error = error {
            connectionSubject.send(completion: .failure(.closedWithError(error)))
        } else {
            connectionSubject.send(.closed)
        }
    }

    public func connectionWillReconnect(error: Error) {
        connectionSubject.send(.willReconnectAfterFailure(error))
    }

    public func connectionDidReconnect() {
        connectionSubject.send(.reconnected)
    }
}
