//
//  HttpConnectionOptions.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/7/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

/**

 */
public class HttpConnectionOptions {
    /**
     A dictionary containing headers to be included in HTTP requests sent by the client.
    */
    public var headers: [String:String] = [:]

    /**
     A factory for creating access tokens that will be included in HTTP requests sent by the client.

     - note: the factory will be called before each http request and will set the `Authorization` token value to: `Bearer {token-returned-by-factory}` unless the returned value is `nil` in which case the `Authorization` header will not be created
    */
    public var accessTokenProvider: () -> String? = { return nil }

    /**
     A factory for creating an HTTP client.

     - note: currently used only by tests
    */
    public var httpClientFactory: (_ options: HttpConnectionOptions) -> HttpClientProtocol = { DefaultHttpClient(options: $0) }

    /**
     Whether to skip the negotiation request when starting a connection.

     - note: the negotiation request can be skipped only when using the WebSockets transport and cannot be skipped when connecting to SignalR Azure Service

    */
    public var skipNegotiation: Bool = false

    /**
     Initializes an `HttpConnectionOptions`.
     */
    public init() {
    }
}
