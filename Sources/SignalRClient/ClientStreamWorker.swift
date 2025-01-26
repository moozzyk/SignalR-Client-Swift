//
//  File.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 1/25/25.
//

import Foundation

internal protocol ClientStreamWorker {
    var streamId: String { get }
    func start()
    func stop()
}
