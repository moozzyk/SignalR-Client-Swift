//
//  CombineHubConnection.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Combine
import Foundation

@available(iOS 13.0, macOS 10.15, *)
public final class CombineHubConnection: ReactiveHubConnection {

    // MARK: - Dependencies

    private(set) var hubConnection: HubConnectionProtocol

    // MARK: - Public Properties

    public var connectionId: String? { hubConnection.connectionId }
    public var connectionPublisher: AnyPublisher<ReactiveHubConnectionEvent, ReactiveHubConnectionFailure> {
        connectionSubject.removeDuplicates().eraseToAnyPublisher()
    }
    public var invocationPublisher: AnyPublisher<ReactiveHubInvocationEvent, ReactiveHubInvocationFailure> {
        invocationSubject.removeDuplicates().eraseToAnyPublisher()
    }
    public var streamPublisher: AnyPublisher<ReactiveHubStreamEvent, ReactiveHubStreamFailure> {
        streamSubject.removeDuplicates().eraseToAnyPublisher()
    }

    // MARK: - Internal Properties

    let connectionSubject: PassthroughSubject<ReactiveHubConnectionEvent, ReactiveHubConnectionFailure> = .init()
    let invocationSubject: PassthroughSubject<ReactiveHubInvocationEvent, ReactiveHubInvocationFailure> = .init()
    let streamSubject: PassthroughSubject<ReactiveHubStreamEvent, ReactiveHubStreamFailure> = .init()

    // MARK: - Initialization

    init(
        url: URL,
        httpConnectionOptions: HttpConnectionOptions,
        transportFactory: TransportFactory,
        logger: Logger,
        hubProtocol: HubProtocol,
        reconnectPolicy: ReconnectPolicy
    ) {
        let connectionFactory: () -> HttpConnection = {
            // HttpConnection may overwrite some properties (most notably accessTokenProvider
            // when connecting to Azure SingalR Service) so needs its own copy to not corrupt
            // the instance provided by the user
            let httpConnectionOptionsCopy = HttpConnectionOptions()
            httpConnectionOptionsCopy.headers = httpConnectionOptions.headers
            httpConnectionOptionsCopy.accessTokenProvider = httpConnectionOptions.accessTokenProvider
            httpConnectionOptionsCopy.httpClientFactory = httpConnectionOptions.httpClientFactory
            httpConnectionOptionsCopy.skipNegotiation = httpConnectionOptions.skipNegotiation
            httpConnectionOptionsCopy.requestTimeout = httpConnectionOptions.requestTimeout
            return HttpConnection(
                url: url,
                options: httpConnectionOptionsCopy,
                transportFactory: transportFactory,
                logger: logger
            )
        }
        let reconnectableConnection = ReconnectableConnection(
            connectionFactory: connectionFactory,
            reconnectPolicy: reconnectPolicy,
            logger: logger
        )
        self.hubConnection = HubConnection(
            connection: reconnectableConnection,
            hubProtocol: hubProtocol,
            logger: logger
        )
        self.hubConnection.delegate = self
    }

    public convenience init(
        url: URL,
        options: HttpConnectionOptions = HttpConnectionOptions(),
        permittedTransportTypes: TransportType = .all,
        reconnectPolicy: ReconnectPolicy? = nil,
        logger: Logger = NullLogger()
    ) {
        let reconnectPolicy = reconnectPolicy ?? NoReconnectPolicy()
        self.init(
            url: url,
            httpConnectionOptions: options,
            transportFactory: DefaultTransportFactory(
                logger: logger,
                permittedTransportTypes: permittedTransportTypes
            ),
            logger: logger,
            hubProtocol: JSONHubProtocol(logger: logger),
            reconnectPolicy: reconnectPolicy
        )
    }

    // MARK: - Public API

    public func start() {
        hubConnection.start()
    }

    public func on(method: String) {
        hubConnection.on(
            method: method,
            callback: { [weak self] argumentExtractor in
                self?.connectionSubject.send(.gotArgumentExtractor(argumentExtractor, forMethod: method))
            }
        )
    }

    public func send(
        method: String,
        arguments: [Encodable]
    ) {
        hubConnection.send(
            method: method,
            arguments: arguments,
            sendDidComplete: { [weak self] error in
                if let error = error {
                    self?.connectionSubject.send(.failedToSendArguments(arguments, toMethod: method, error: error))
                } else {
                    self?.connectionSubject.send(.succesfullySentArguments(arguments, toMethod: method))
                }
            }
        )
    }

    public func invoke(
        method: String,
        arguments: [Encodable]
    ) {
        hubConnection.invoke(
            method: method,
            arguments: arguments,
            invocationDidComplete: { [weak self] error in
                if let error = error {
                    self?.invocationSubject.send(completion: .failure(.invokeCompletedWithError(error)))
                } else {
                    self?.invocationSubject.send(.invocationCompleted(forMethod: method, withArguments: arguments))
                }
            }
        )
    }

    public func invoke<T>(
        method: String,
        arguments: [Encodable],
        resultType: T.Type
    ) where T : Decodable {
        hubConnection.invoke(
            method: method,
            arguments: arguments,
            resultType: resultType,
            invocationDidComplete: { [weak self] response, error in
                if let error = error {
                    self?.invocationSubject.send(completion: .failure(.invokeCompletedWithError(error)))
                } else {
                    var item: InvocationItem? = nil
                    if let response = response {
                        item = .init(response)
                    }
                    self?.invocationSubject.send(.itemReceived(item, fromMethod: method, withArguments: arguments))
                }
            }
        )
    }

    public func stream<T>(
        method: String,
        arguments: [Encodable],
        streamResultType: T.Type
    ) -> StreamHandle where T : Decodable {
        return hubConnection.stream(
            method: method, arguments: arguments,
            streamItemReceived: { [weak self] (value: T) in
                let item: StreamItem = .init(value)
                self?.streamSubject.send(.itemReceived(item, fromMethod: method, withArguments: arguments))
            },
            invocationDidComplete: { [weak self] error in
                if let error = error {
                    self?.streamSubject.send(completion: .failure(.streamCompletedWithError(error)))
                } else {
                    self?.streamSubject.send(.streamInvocationCompleted(forMethod: method, withArguments: arguments))
                }
            }
        )
    }

    public func cancelStreamInvocation(streamHandle: StreamHandle) {
        hubConnection.cancelStreamInvocation(
            streamHandle: streamHandle,
            cancelDidFail: { [weak self] error in
                self?.streamSubject.send(.cancelationFailed(forHandle: streamHandle, withError: error))
            }
        )
    }

    public func stop() {
        hubConnection.stop()
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension CombineHubConnection: HubConnectionDelegate {
    public func connectionDidOpen(hubConnection: HubConnection) {
        connectionSubject.send(.opened(hubConnection))
    }

    public func connectionDidFailToOpen(error: Error) {
        connectionSubject.send(completion: .failure(.failedToOpen(error)))
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
