//
//  ConnectionDelegate.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol SocketConnectionDelegate: class {
    func connectionDidOpen(connection: SocketConnection!);
    func connectionDidFailToOpen(error: Error);
    func connectionDidReceiveData(connection: SocketConnection!, data: Data);
    func connectionDidClose(error: Error?);
}
