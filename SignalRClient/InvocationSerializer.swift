//
//  InvocationSerializer.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/18/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol InvocationSerializer {
    func writeInvocationDescriptor(invocationDescriptor: InvocationDescriptor) throws -> Data
    func processIncomingData(data: Data) throws -> AnyObject
}
