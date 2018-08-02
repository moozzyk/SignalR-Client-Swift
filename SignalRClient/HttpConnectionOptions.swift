//
//  HttpConnectionOptions.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/7/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HttpConnectionOptions {
    public var headers: [String:String] = [:]
    public var accessTokenProvider: () -> String? = { return nil }
    public var httpClientFactory: (_ options: HttpConnectionOptions) -> HttpClientProtocol = { DefaultHttpClient(options: $0) }

    public init() {
    }
}
