//
//  HubConnectionDelegate.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol HubConnectionDelegate: class {
    func connectionDidOpen(hubConnection: HubConnection!)
    func connectionDidFailToOpen(error: Error)
    func connectionDidClose(error: Error?)
}
