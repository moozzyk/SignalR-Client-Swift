//
//  SignalRError.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/9/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum SignalRError : Error {
    case invalidState
    case webError(statusCode: Int)
    case hubInvocationError(message: String)
    case hubInvocationCancelled
    case unknownMessageType
    case invalidMessage
    case unsupportedType
    case connectionIsBeingClosed
    case invalidOperation(message: String)
    case protocolViolation
    case handshakeError(message: String)
    case invalidNegotiationResponse(message: String)
    case serverClose(message: String?)
    case noSupportedTransportAvailable
}
