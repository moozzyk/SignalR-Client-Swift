//
//  Util.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 4/13/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

internal class Util {
    public static func dispatchToMainThread(action: @escaping () -> Void) {
        DispatchQueue.main.async(execute: action)
    }
}
