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
