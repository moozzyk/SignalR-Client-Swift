//
//  DefaultHttpClient.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

class DefaultHttpClient {
    func get(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "GET", completionHandler: completionHandler)
    }

    func post(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "POST", completionHandler: completionHandler)
    }

    func sendHttpRequest(url:URL, method:String, completionHandler: @escaping (HttpResponse?, Error?) -> Swift.Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
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
