//
//  StreamHandle.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/6/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//
import Foundation

public class StreamHandle {
    internal let invocationId: String
    internal init(invocationId: String) {
        self.invocationId = invocationId
    }
}
