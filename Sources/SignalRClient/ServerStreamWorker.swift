//
//  File.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 1/25/25.
//

import Foundation

internal protocol ServerStreamWorker {
    var streamId: String { get }
    func start()
    func stop()
}

internal struct DummyServerStreamWorker: ServerStreamWorker {
    public private(set) var streamId: String

    init(streamId: String) {
        self.streamId = streamId
    }

    func start() {
    }

    func stop() {
    }
}
