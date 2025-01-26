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

    func transportDidOpen() {
        transportDidOpenHandler?()
    }

    func transportDidReceiveData(_ data: Data) {
        transportDidReceiveDataHandler?(data)
    }

    func transportDidClose(_ error: Error?) {
        transportDidCloseHandler?(error)
    }
}
