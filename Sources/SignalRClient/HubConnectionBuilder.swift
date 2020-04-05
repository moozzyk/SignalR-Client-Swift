//
//  HubConnectionBuilder.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/8/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

/**
 A helper class that makes creating and configuring `HubConnection`s easy.

 Typical usage:
 ```
 let hubConnection = HubConnectionBuilder(url: URL(string: "http://localhost:5000/playground")!)
    .withLogging(minLogLevel: .info)
    .build()
 ```
 */
public class HubConnectionBuilder {
    private let url: URL
    private var hubProtocolFactory: (Logger) -> HubProtocol = {logger in JSONHubProtocol(logger: logger)}
    private let httpConnectionOptions = HttpConnectionOptions()
    private var logger: Logger = NullLogger()
    private var delegate: HubConnectionDelegate?
    private var reconnectPolicy: ReconnectPolicy = NoReconnectPolicy()
    private var useLegacyHttpConnection = false

    /**
     Initializes a `HubConnectionBuilder` with a URL.

     - parameter url: A URL to the SignalR server
     */
    public init(url: URL) {
        self.url = url
    }

    /**
     Allows configuring a factory that creates a `HubProtocol` to be used by the client.

     - parameter hubProtocolFactory: a factory for creating the `HubProtocol` used by the client
     - note: By default the client will use the `JSONHubProtocol`.
    */
    public func withHubProtocol(hubProtocolFactory: @escaping (Logger) -> HubProtocol) -> HubConnectionBuilder {
        self.hubProtocolFactory = hubProtocolFactory
        return self
    }

    /**
     Allows configuring HTTP options (e.g. headers or authorization tokens).

     - parameter configureHttpOptions: a callback allowing to configure HTTP options
    */
    public func withHttpConnectionOptions(configureHttpOptions: (_ httpConnectionOptions: HttpConnectionOptions) -> Void) -> HubConnectionBuilder {
        configureHttpOptions(httpConnectionOptions)
        return self
    }

    /**
     Allows configuring `PrintLogger` logging.

     - parameter minLogLevel: minimum log level
     - note: By default logging is disabled. When using this overload all log entries whose level is greater or equal than `minLogLevel` will be written using the `print` function.
     */
    public func withLogging(minLogLevel: LogLevel) -> HubConnectionBuilder {
        logger = FilteringLogger(minLogLevel: minLogLevel, logger: PrintLogger())
        return self
    }

    /**
     Allows setting a custom logger.

     The custom logger will receive all log entries written by the client.
     - parameter logger: custom logger
     */
    public func withLogging(logger: Logger) -> HubConnectionBuilder {
        self.logger = logger
        return self
    }

    /**
     Allows setting a custom logger and the minimum log level.

     The log entries sent to the custom logger will be prefiltered and the logger will receive only the entries whose whose log level is greator or equal than `minLogLevel`.

     - parameter minLogLevel: minimum log level
     - parameter logger: custom logger
     */
    public func withLogging(minLogLevel: LogLevel, logger: Logger) -> HubConnectionBuilder {
        self.logger = FilteringLogger(minLogLevel: minLogLevel, logger: logger)
        return self
    }

    /**
     Allows setting a `HubConnectionDelegate` that will receive hub connection lifecycle events.

     - parameter delegate: a `HubConnectionDelegate` that will receive hub connection lifecycle events
     - note: The user is responsible for maintaining the reference to the delegate.
     */
    public func withHubConnectionDelegate(delegate: HubConnectionDelegate) -> HubConnectionBuilder {
        self.delegate = delegate
        return self
    }

    /**
    Allows enablbing and configuring automatic reconnection in case the connection was closed

     - parameter reconnectPolicy: allows setting a reconnect policy that configures reconnection
     - note: by default the connection is not reconnectable. Calling this method makes it reconnectable. If no `reconnectPolicy` is provided the `DefaultReconnectPolicy` will be used.
     */
    public func withAutoReconnect(reconnectPolicy: ReconnectPolicy = DefaultReconnectPolicy()) -> HubConnectionBuilder {
        self.reconnectPolicy = reconnectPolicy
        return self
    }

    /**
    In case support for automatic reconnects  introduces issues this method allows to get to the previous behavior. It should be treated as an emergency measure only and will be removed in future versions.
     */
    public func withLegacyHttpConnection() -> HubConnectionBuilder {
        useLegacyHttpConnection = true
        return self
    }

    /**
     Creates a new `HubConnection` using requested configuration.

     - returns: a new `HubConnection` configured as requested
     */
    public func build() -> HubConnection {
        let hubConnection = HubConnection(connection: createHttpConnection(), hubProtocol: hubProtocolFactory(logger), logger: logger)
        hubConnection.delegate = delegate
        return hubConnection
    }

    private func createHttpConnection() -> Connection {
        if useLegacyHttpConnection {
            if !(reconnectPolicy is NoReconnectPolicy) {
                logger.log(logLevel: .error, message: "Using reconnect with legacy HttpConnection is not supported. Ignoring reconnect settings.")
            }
            return HttpConnection(url: url, options: httpConnectionOptions, logger: logger)
        }

        let connectionFactory = {return HttpConnection(url: self.url, options: self.httpConnectionOptions, logger: self.logger)}
        return ReconnectableConnection(connectionFactory: connectionFactory, reconnectPolicy: reconnectPolicy, logger: self.logger)
    }
}

public extension HubConnectionBuilder {
    /**
     A convenience method for configuring a `HubConnection` to use the `JSONHubProtocol`.
     */
    func withJSONHubProtocol() -> HubConnectionBuilder {
        return self.withHubProtocol(hubProtocolFactory: {logger in JSONHubProtocol(logger: logger)})
    }
}
