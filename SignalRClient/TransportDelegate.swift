//
//  TransportDelegate.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/25/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol TransportDelegate: class {
    func transportDidOpen() -> Void
    func transportDidReceiveData(_ data: Data) -> Void
    func transportDidClose(_ error: Error?) -> Void
}
