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
    private var hubProtocol: HubProtocol = JSONHubProtocol()
    private let httpConnectionOptions = HttpConnectionOptions()

    public init(url: URL) {
        self.url = url
    }

    public func withHubProtocol(hubProtocol: HubProtocol) -> HubConnectionBuilder {
        self.hubProtocol = hubProtocol
        return self
    }

    public func withHttpConnectionOptions(configureHttpOptions: (_ httpConnectionOptions: HttpConnectionOptions) -> Void) -> HubConnectionBuilder {
        configureHttpOptions(httpConnectionOptions)
        return self
    }

    public func build() -> HubConnection {
        let httpConnection = HttpConnection(url: url, options: httpConnectionOptions)
        return HubConnection(connection: httpConnection, hubProtocol: hubProtocol)
    }
}

public extension HubConnectionBuilder {
    func withJSONHubProtocol(typeConverter: TypeConverter = JSONTypeConverter()) -> HubConnectionBuilder {
        return self.withHubProtocol(hubProtocol: JSONHubProtocol(typeConverter: typeConverter))
    }
}
