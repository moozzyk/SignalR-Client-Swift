//
//  WebsocketsTransportTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/23/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class WebsocketsTransportTests: SignalRClientTestCase {

    func testThatWebsocketsTransportCanSendAndReceiveMessage() throws {
        try XCTSkipIf(runningWithoutLiveServer)
        let didOpenExpectation = expectation(description: "transport opened")
        let didReceiveDataExpectation = expectation(description: "transport received data")
        let didCloseExpectation = expectation(description: "transport closed")

        let wsTransport = WebsocketsTransport(logger: NullLogger())
        let transportDelegate = TestTransportDelegate()
        let message = "Hello, World!"

        transportDelegate.transportDidOpenHandler = {

            wsTransport.send(data: message.data(using: .utf8)!) { error in
                if let e = error {
                    print(e)
                }
            }
            didOpenExpectation.fulfill()
        }

        transportDelegate.transportDidReceiveDataHandler = { data in
            wsTransport.close()
            XCTAssertEqual(message, String(data: data, encoding: .utf8))
            didReceiveDataExpectation.fulfill()
        }

        transportDelegate.transportDidCloseHandler = { error in
            didCloseExpectation.fulfill()
        }

        wsTransport.delegate = transportDelegate
        wsTransport.start(url: ECHO_WEBSOCKETS_URL, options: HttpConnectionOptions())
        
        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testHasInherentKeepAlive() {
        XCTAssertFalse(WebsocketsTransport(logger: NullLogger()).inherentKeepAlive)
    }
}
