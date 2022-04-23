//
//  TestTransport.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/27/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation
@testable import SignalRClient

typealias TestTransport = MockTransport

class MockTransport: Transport {
    weak var delegate: TransportDelegate?
    var inherentKeepAlive: Bool = false

    func start(url:URL, options: HttpConnectionOptions = HttpConnectionOptions()) -> Void {
        delegate?.transportDidOpen()
    }

    func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
    }

    func close() -> Void {
        delegate?.transportDidClose(nil)
    }
}
