//
//  HubConnectionDelegate.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol HubDelegate: class {
    func connectionDidOpen(connection: HubConnection!);
    func connectionDidFailToOpen(error: Error);

    // func On ?

    func connectionDidClose(error: Error?);
}
