//
//  HubConnectionTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient


class TestHubConnectionDelegate: HubConnectionDelegate {
    var connectionDidOpenHandler: ((_ hubConnection: HubConnection) -> Void)?
    var connectionDidFailToOpenHandler: ((_ error: Error) -> Void)?
    var connectionDidCloseHandler: ((_ error: Error?) -> Void)?

    func connectionDidOpen(hubConnection: HubConnection!) {
        connectionDidOpenHandler?(hubConnection)
    }

    func connectionDidFailToOpen(error: Error) {
        connectionDidFailToOpenHandler?(error)
    }

    func connectionDidClose(error: Error?) {
        connectionDidCloseHandler?(error)
    }
}

class HubConnectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatHubMethodCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let message = "Hello, World!"
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "Echo", arguments: [message], returnType: String.self, invocationDidComplete: { result, error in
                XCTAssertNil(error)
                XCTAssertEqual(message, result)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!, query: "formatType=json")
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatVoidHubMethodCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "VoidMethod", arguments: [], invocationDidComplete: { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!, query: "formatType=json")
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }


    func testThatExceptionsInHubMethodsAreTrunedIntoErrors() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "ErrorMethod", arguments: [], returnType: String.self, invocationDidComplete: { result, error in
                XCTAssertNotNil(error)

                switch (error as! SignalRError) {
                case .hubInvocationError(let errorMessage):
                    XCTAssertEqual("Error occurred.", errorMessage)
                    break
                default:
                    XCTAssertTrue(false)
                    break
                }

                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!, query: "formatType=json")
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
