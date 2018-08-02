//
//  DefaultHttpClient.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

class DefaultHttpClient: HttpClientProtocol {
    private let options: HttpConnectionOptions

    public init(options: HttpConnectionOptions) {
        self.options = options
    }
    
    func get(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "GET", completionHandler: completionHandler)
    }

    func post(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "POST", completionHandler: completionHandler)
    }

    func sendHttpRequest(url:URL, method:String, completionHandler: @escaping (HttpResponse?, Error?) -> Swift.Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        populateHeaders(headers: options.headers, request: &urlRequest)
        setAccessToken(accessTokenProvider: options.accessTokenProvider, request: &urlRequest)
        
        let session = URLSession.shared

        session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in

            var resp:HttpResponse?
            if error == nil {
                resp = HttpResponse(statusCode: (response as! HTTPURLResponse).statusCode, contents: data)
            }

            completionHandler(resp, error)
        }).resume()
    }
    
    @inline(__always) private func populateHeaders(headers: [String : String], request: inout URLRequest) {
        headers.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
    }

    @inline(__always) private func setAccessToken(accessTokenProvider: () -> String?, request: inout URLRequest) {
        if let accessToken = accessTokenProvider() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
}
