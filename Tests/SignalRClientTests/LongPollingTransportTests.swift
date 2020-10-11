//
//  LongPollingTransportTests.swift
//  SignalRClient
//
//  Created by David Robertson on 14/07/2020.
//

import Foundation


import XCTest
@testable import SignalRClient

class LongPollingTransportTests: XCTestCase {

    func testThatLongPollingTransportCanSendAndReceiveMessage() {
        let didOpenExpectation = expectation(description: "transport opened")
        let didReceiveDataExpectation = expectation(description: "transport received data")
        let didCloseExpectation = expectation(description: "transport closed")

        let lpTransport = LongPollingTransport(logger: PrintLogger())
        let transportDelegate = TestTransportDelegate()
        let message = "Hello, World!"

        transportDelegate.transportDidOpenHandler = {
            lpTransport.send(data: message.data(using: .utf8)!) { error in
                if let e = error {
                    print(e)
                }
            }
            didOpenExpectation.fulfill()
        }

        transportDelegate.transportDidReceiveDataHandler = { data in
            lpTransport.close()
            XCTAssertEqual(message, String(data: data, encoding: .utf8))
            didReceiveDataExpectation.fulfill()
        }

        transportDelegate.transportDidCloseHandler = { error in
            didCloseExpectation.fulfill()
        }

        lpTransport.delegate = transportDelegate
        
        let sessionUrl = getSessionUrl()
        lpTransport.start(url: sessionUrl, options: HttpConnectionOptions())
        
        waitForExpectations(timeout: 5 /*seconds*/)
    }
    
    
    func getSessionUrl() -> URL {
        // Unlike the websockets test, we can't get away without doing negotiation.
        // This is a simple implementation of the negotiation process to decouple this test from the real negotiation code.
        // This does not handle all possible circumstances but it works with the TestServer setup.
        let endpoint = ECHO_LONGPOLLING_URL.absoluteString
        let negotiateUrl = URL(string: "\(endpoint)/negotiate?negotiateVersion=1")!
        var urlRequest = URLRequest(url: negotiateUrl)
        urlRequest.httpMethod = "POST"
        
        self.continueAfterFailure = false
        let negotiateRequestExpectation = expectation(description: "negotiate response received")
        var responseData: Data? = nil
        let task = URLSession.shared.dataTask(with: urlRequest) { (dataOptional, responseOptional, errorOptional) in
            if let response = responseOptional as? HTTPURLResponse, let data = dataOptional, errorOptional == nil, response.statusCode == 200 {
                responseData = data
                negotiateRequestExpectation.fulfill()
            } else {
                XCTFail("Error negotiating session: error=\(String(describing: errorOptional)) response=\(String(describing: responseOptional)) data=\(String(describing: dataOptional))")
            }
        }
        task.resume()
        wait(for: [negotiateRequestExpectation], timeout: 5)
        XCTAssertNotNil(responseData)
        
        let response = try! NegotiationPayloadParser.parse(payload: responseData) as! NegotiationResponse
        let connectionId = response.connectionToken!
        let connectionUrl = URL(string: "\(endpoint)?id=\(connectionId)")!
        return connectionUrl
    }
}
