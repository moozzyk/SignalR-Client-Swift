//
//  ReconnectableConnectionTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 11/23/19.
//
import XCTest
@testable import SignalRClient

class ReconnectableConnectionTests: XCTestCase {
    public func testThatConnectionDoesNotReconnectIfReconnectPolicyReturnsNever() {
        let didCloseExpectation = expectation(description: "connection closed")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: NoReconnectPolicy(), logger: PrintLogger())

        delegate.connectionDidOpenHandler = { connection in
            testConnection.delegate?.connectionDidClose(error: SignalRError.invalidOperation(message: "error"))
        }

        delegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
        }

        reconnectableConnection.delegate = delegate
        reconnectableConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    public func testThatConnectionReconnectsIfReconnectPolicyAllowsIt() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didCloseExpectation = expectation(description: "connection closed")
        let willReconnectExpectation = expectation(description: "connection will reconnect")
        let didReconnectExpectation = expectation(description: "connection reconnected")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), logger: PrintLogger())

        delegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            testConnection.delegate?.connectionDidClose(error: SignalRError.invalidOperation(message: "forcing reconnect"))
        }

        delegate.connectionWillReconnectHandler = { error in
            switch (error as! SignalRError) {
            case .invalidOperation(let errorMessage):
                XCTAssertEqual("forcing reconnect", errorMessage)
                break
            default:
                XCTFail()
                break
            }
            willReconnectExpectation.fulfill()
        }

        delegate.connectionDidReconnectHandler = {
            didReconnectExpectation.fulfill()
            reconnectableConnection.stop(stopError: nil)
        }

        delegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        reconnectableConnection.delegate = delegate
        reconnectableConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    public func testThatConnectionDoesNotReconnectIfAllowedAttemptsExhausted() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didCloseExpectation = expectation(description: "connection closed")
        let willReconnectExpectation = expectation(description: "connection will reconnect")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10), .milliseconds(10), .milliseconds(10)]), logger: PrintLogger())

        delegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            testConnection.openError = SignalRError.invalidNegotiationResponse(message: "Negotiation failed")
            testConnection.delegate?.connectionDidClose(error: SignalRError.invalidOperation(message: "forcing reconnect"))
        }

        delegate.connectionWillReconnectHandler = { error in
            switch (error as! SignalRError) {
            case .invalidOperation(let errorMessage):
                XCTAssertEqual("forcing reconnect", errorMessage)
                break
            default:
                XCTFail()
                break
            }
            willReconnectExpectation.fulfill()
        }

        delegate.connectionDidCloseHandler = { error in
            XCTAssertNotNil(error)
            switch (error as! SignalRError) {
            case .invalidNegotiationResponse(let errorMessage):
                XCTAssertEqual("Negotiation failed", errorMessage)
                break
            default:
                XCTFail()
                break
            }
            didCloseExpectation.fulfill()
        }

        reconnectableConnection.delegate = delegate
        reconnectableConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    public func testThatSendingDuringReconnectReturnsError() {
        let didCloseExpectation = expectation(description: "connection closed")
        let sendDidFail = expectation(description: "send failed")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), logger: PrintLogger())

        delegate.connectionDidOpenHandler = { _ in
            testConnection.delegate?.connectionDidClose(error: SignalRError.invalidOperation(message: "forcing reconnect"))
            reconnectableConnection.send(data: "Should fail".data(using: .utf8)!) { error in
                XCTAssertNotNil(error)
                XCTAssertEqual(String(describing: error!), String(describing: SignalRError.connectionIsReconnecting))
                reconnectableConnection.stop(stopError: nil)
                sendDidFail.fulfill()
            }
        }

        delegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        reconnectableConnection.delegate = delegate
        reconnectableConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    public func testReconnectableConnectionForwardsInherentKeepAliveFromConnection() {
        for inherentKeepAlive in [true, false] {
            let testConnection = TestConnection()
            testConnection.inherentKeepAlive = inherentKeepAlive
            let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), logger: PrintLogger())
            XCTAssertEqual(inherentKeepAlive, reconnectableConnection.inherentKeepAlive)
        }
    }

    class TestConnection: Connection {
        var delegate: ConnectionDelegate?
        var openError: Error?

        var connectionId: String?
        var inherentKeepAlive = false

        func start() {
            if let e = openError {
                delegate?.connectionDidFailToOpen(error: e)
            } else {
                delegate?.connectionDidOpen(connection: self)
            }
        }

        func send(data: Data, sendDidComplete: (Error?) -> Void) {
            sendDidComplete(nil)
        }

        func stop(stopError: Error?) {
            delegate?.connectionDidClose(error: stopError)
        }
    }
}
