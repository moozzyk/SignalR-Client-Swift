//
//  HubConnectionBuilder.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/8/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HubConnectionBuilder {
    private let url: URL
    private var hubProtocolFactory: (Logger) -> HubProtocol = {logger in JSONHubProtocol(typeConverter: JSONTypeConverter(), logger: logger)}
    private let httpConnectionOptions = HttpConnectionOptions()
    private var logger: Logger = NullLogger()

    public init(url: URL) {
        self.url = url
    }

    public func withHubProtocol(hubProtocolFactory: @escaping (Logger) -> HubProtocol) -> HubConnectionBuilder {
        self.hubProtocolFactory = hubProtocolFactory
        return self
    }

    public func withHttpConnectionOptions(configureHttpOptions: (_ httpConnectionOptions: HttpConnectionOptions) -> Void) -> HubConnectionBuilder {
        configureHttpOptions(httpConnectionOptions)
        return self
    }

    public func withLogging(minLogLevel: LogLevel) -> HubConnectionBuilder {
        logger = FilteringLogger(minLogLevel: minLogLevel, logger: PrintLogger())
        return self
    }

    public func withLogging(logger: Logger) -> HubConnectionBuilder {
        self.logger = logger
        return self
    }

    public func withLogging(minLogLevel: LogLevel, logger: Logger) -> HubConnectionBuilder {
        self.logger = FilteringLogger(minLogLevel: minLogLevel, logger: logger)
        return self
    }

    public func build() -> HubConnection {
        let httpConnection = HttpConnection(url: url, options: httpConnectionOptions, logger: logger)
        return HubConnection(connection: httpConnection, hubProtocol: hubProtocolFactory(logger), logger: logger)
    }
}

public extension HubConnectionBuilder {
    func withJSONHubProtocol(typeConverter: TypeConverter = JSONTypeConverter()) -> HubConnectionBuilder {
        return self.withHubProtocol(hubProtocolFactory: {logger in JSONHubProtocol(typeConverter: typeConverter, logger: logger)})
    }
}
