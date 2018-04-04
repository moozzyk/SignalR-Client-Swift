//
//  DefaultHttpClient.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public struct HTTPHeader {
    var header: String
    var value: String
    
    public init(header: String, value: String) {
        self.header = header
        self.value = value
    }
}

class DefaultHttpClient {
    func get(url: URL, headers: [HTTPHeader], completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "GET", headers: headers, completionHandler: completionHandler)
    }

    func post(url: URL, headers: [HTTPHeader], completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "POST", headers: headers, completionHandler: completionHandler)
    }

    func sendHttpRequest(url:URL, method:String, headers: [HTTPHeader], completionHandler: @escaping (HttpResponse?, Error?) -> Swift.Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        headers.forEach{ urlRequest.setValue($0.value, forHTTPHeaderField: $0.header) }
        
        let session = URLSession.shared

        session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in

            var resp:HttpResponse?
            if error == nil {
                resp = HttpResponse(statusCode: (response as! HTTPURLResponse).statusCode, contents: data)
            }

            completionHandler(resp, error)
        }).resume()
    }
}
