//
//  HttpResponse.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HttpResponse {
    let statusCode: Int
    let contents: Data?

    init(statusCode: Int, contents: Data?) {
        self.statusCode = statusCode
        self.contents = contents
    }
}
