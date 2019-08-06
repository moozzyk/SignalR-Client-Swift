//
//  StreamHandle.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/6/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//
import Foundation

/**
 A handle indentifying a stream.

 The handle is returned by the `HubConnection.stream` method and is required to cancel an active stream invocation.
 */
public class StreamHandle {
    internal let invocationId: String
    internal init(invocationId: String) {
        self.invocationId = invocationId
    }
}
