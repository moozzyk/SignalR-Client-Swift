//
//  HttpClientProtocol.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 7/30/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

public protocol HttpClientProtocol {
    func get(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void)
    func post(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void)
}
