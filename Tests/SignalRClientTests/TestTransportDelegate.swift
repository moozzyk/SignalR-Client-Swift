//
//  TestTransportDelegate.swift
//  SignalRClientTests
//
//  Created by David Robertson on 14/07/2020.
//

import Foundation
@testable import SignalRClient

class TestTransportDelegate: TransportDelegate {
    var transportDidOpenHandler: (() -> Void)?
    var transportDidReceiveDataHandler: ((_ data: Data) -> Void)?
    var transportDidCloseHandler: ((_ error: Error?) -> Void)?

    func transportDidOpen() -> Void {
        transportDidOpenHandler?()
    }

    func transportDidReceiveData(_ data: Data) -> Void {
        transportDidReceiveDataHandler?(data)
    }

    func transportDidClose(_ error: Error?) -> Void {
        transportDidCloseHandler?(error)
    }
}
