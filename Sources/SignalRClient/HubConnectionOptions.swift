//
//  HubConnectionOptions.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 10/4/21.
//

import Foundation

/**
 HubConnection configuration options.
 */
public class HubConnectionOptions {
    /**
     Keep-alive interval in seconds. If nil keep-alive is disabled
     */
    public var keepAliveInterval: Double? = nil

    /**
     Initializes `HubConnectionOptions`
     */
    public init() {
    }
}
