//
//  TestTransport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

@testable import SignalRClient

class TestTransport: Transport {
    weak var delegate: TransportDelegate?
    var inherentKeepAlive: Bool = false

    func start(url: URL, options: HttpConnectionOptions = HttpConnectionOptions()) {
        delegate?.transportDidOpen()
    }

    func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
    }

    func close() {
        delegate?.transportDidClose(nil)
    }
}
