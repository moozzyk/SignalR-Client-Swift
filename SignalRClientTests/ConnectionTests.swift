//
//  ConnectionTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class TestConnectionDelegate: SocketConnectionDelegate {
    var connectionDidOpenHandler: ((_ connection: SocketConnection) -> Void)?
    var connectionDidFailToOpenHandler: ((_ error: Error) -> Void)?
    var connectionDidCloseHandler: ((_ error: Error?) -> Void)?
    var connectionDidReceiveDataHandler: ((_ connection: SocketConnection, _ data: Data) -> Void)?

    func connectionDidOpen(connection: SocketConnection!) {
        connectionDidOpenHandler?(connection)
    }

    func connectionDidFailToOpen(error: Error) {
        connectionDidFailToOpenHandler?(error)
    }

    func connectionDidReceiveData(connection: SocketConnection!, data: Data) {
        connectionDidReceiveDataHandler?(connection, data)
    }

    func connectionDidClose(error: Error?) {
        connectionDidCloseHandler?(error)
    }
}

class ConnectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatConnectionCanSendReceiveMessages() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveMessageExpectation = expectation(description: "message received")
        let didCloseExpectation = expectation(description: "connection closed")

        let message = "Hello, World!"
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            do {
                try connection.send(data: message.data(using: .utf8)!)
                didOpenExpectation.fulfill()
            } catch {
                print(error)
            }
        }

        connectionDelegate.connectionDidReceiveDataHandler = { connection, data in
            XCTAssertEqual(message, String(data: data, encoding: .utf8))
            didReceiveMessageExpectation.fulfill()
            connection.stop()
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatOpeningConnectionFailsIfConnectionNotInInitialState() {
        let didFailToOpenExpectation = expectation(description: "connection failed to open")
        let didCloseExpectation = expectation(description: "connection closed")

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            connection.stop()
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
        }

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpenExpectation.fulfill()
        }

        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        connection.delegate = connectionDelegate
        connection.start()
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionDidFailToOpenInvokedIfCantConnectToServer() {
        let didFailToOpenExpectation = expectation(description: "connection failed to open")

        let connectionDelegate = TestConnectionDelegate()

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpenExpectation.fulfill()
        }

        let connection = Connection(url: URL(string: "http://localhost:1000/echo")!)
        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionDidFailToOpenInvokedIfHttpResponseNotOK() {
        let didFailToOpenExpectation = expectation(description: "connection failed to open")

        let connectionDelegate = TestConnectionDelegate()

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpenExpectation.fulfill()
        }

        let connection = Connection(url: URL(string: "http://localhost:5000/throw")!)
        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedBeforeStartingConnection() {
        let connection = Connection(url: URL(string: "http://fakeuri.org")!)

        XCTAssertThrowsError(try connection.send(data: "".data(using: .utf8)!), "", { error in
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidState))
        })
    }

    func testThatSendThrowsIfInvokedAfterConnectionFailedToStart() {
        let sendFailedExpectation = expectation(description: "send failed")
        let connection = Connection(url: URL(string: "http://localhost:5000/throw")!)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            do {
                try connection.send(data: "".data(using: .utf8)!)
            } catch SignalRError.invalidState {
                sendFailedExpectation.fulfill()
            } catch {
                print(error)
            }
        }

        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedAfterConnectionClosed() {
        let sendFailedExpectation = expectation(description: "send failed")

        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        let testTransport = TestTransport()
        let connectionDelegate = TestConnectionDelegate()

        connectionDelegate.connectionDidOpenHandler = { connection in
            testTransport.delegate.transportDidClose(nil)
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            do {
                try connection.send(data: "".data(using: .utf8)!)
            } catch SignalRError.invalidState {
                sendFailedExpectation.fulfill()
            } catch {
                print(error)
            }
        }

        connection.delegate = connectionDelegate
        connection.start(transport: testTransport)

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedAfterConnectionStopped() {
        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        connection.start()
        connection.stop()

        XCTAssertThrowsError(try connection.send(data: "".data(using: .utf8)!), "", { error in
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidState))
        })
    }

    func testThatCantStartConnectionAfterItWasStopped() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didCloseExpectation = expectation(description: "connection closed")
        let didFailToOpen = expectation(description: "connection failed to open")

        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            connection.stop()
        }
        connectionDelegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
            XCTAssertNil(error)
            connection.start()
        }
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpen.fulfill()
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidState))
        }

        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatCantStartConnectionThatIsStarting() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didFailToOpen = expectation(description: "connection failed to open")

        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            connection.stop()
        }
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpen.fulfill()
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidState))
        }

        connection.delegate = connectionDelegate
        connection.start()
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatCantStartConnectionThatIsAlreadyRunning() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didCloseExpectation = expectation(description: "connection closed")
        let didFailToOpen = expectation(description: "connection failed to open")

        let connection = Connection(url: URL(string: "http://localhost:5000/echo")!)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            connection.start(transport: nil)
        }
        connectionDelegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
            XCTAssertNil(error)
        }
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpen.fulfill()
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.invalidState))
            connection.stop()
        }

        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }
}
