//
//  DefaultHttpClient.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

class DefaultHttpClient: NSObject, HttpClientProtocol {
    private let options: HttpConnectionOptions
    private var session: URLSession!

    public init(options: HttpConnectionOptions) {
        self.options = options
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = options.requestTimeout
        super.init()
        self.session = URLSession(
            configuration: sessionConfig,
            delegate: self,
            delegateQueue: nil
        )
    }
    
    func get(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "GET", body: nil, completionHandler: completionHandler)
    }

    func post(url: URL, body: Data?, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "POST", body: body, completionHandler: completionHandler)
    }
    
    func delete(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        sendHttpRequest(url:url, method: "DELETE", body: nil, completionHandler: completionHandler)
    }
    

    func sendHttpRequest(url: URL, method: String, body: Data?, completionHandler: @escaping (HttpResponse?, Error?) -> Swift.Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = body
        populateHeaders(headers: options.headers, request: &urlRequest)
        setAccessToken(accessTokenProvider: options.accessTokenProvider, request: &urlRequest)
        
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

extension DefaultHttpClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, nil)
        }
        
        if let challengeHandler = options.authenticationChallengeHandler {
            challengeHandler(session, challenge, completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
