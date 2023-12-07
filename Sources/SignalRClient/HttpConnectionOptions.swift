//
//  HttpConnectionOptions.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/7/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

/**
HttpConnection configuration options.
 */
public class HttpConnectionOptions {
    /**
     A dictionary containing headers to be included in HTTP requests sent by the client.
    */
    public var headers: [String:String] = [:]

    /**
     A factory for creating access tokens that will be included in HTTP requests sent by the client.

     - note: the factory will be called before each http request and will set the `Authorization` header value to: `Bearer {token-returned-by-factory}` unless
             the returned value is `nil` in which case the `Authorization` header will not be created
    */
    public var accessTokenProvider: () -> String? = { return nil }

    /**
     A factory for creating an HTTP client.
    */
    public var httpClientFactory: (_ options: HttpConnectionOptions) -> HttpClientProtocol = { DefaultHttpClient(options: $0) }

    /**
     Whether to skip the negotiation request when starting a connection.

     - note: the negotiation request can be skipped only when using the WebSockets transport and cannot be skipped when connecting to SignalR Azure Service
    */
    public var skipNegotiation: Bool {
        get { return skipNegotiationValue }
        
        @available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
        set { skipNegotiationValue = newValue }
    }
    private var skipNegotiationValue = false

    /**
    The timeout value for individual requests, in seconds.
     */
    public var requestTimeout: TimeInterval = 120

    /**
     The maximum number of bytes to buffer before the receive call fails with an error.

     This value includes the sum of all bytes from continuation frames. Receive calls will fail once the task reaches this limit. (URLSessionWebSocketTask)
    */
    public var maximumWebsocketMessageSize: Int?

    public var authenticationChallengeHandler: ((_ session: URLSession, _ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void)?

    /**
    The queue to run callbacks on
     */
    public var callbackQueue: DispatchQueue = DispatchQueue(label: "SignalR.connection.callbackQueue")

    /**
     Initializes an `HttpConnectionOptions`.
     */
    public init() {
    }
}
