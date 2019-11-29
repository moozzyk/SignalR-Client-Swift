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

    // TODO: enable the test after adding reconnect callbacks
    public func XtestThatConnectionReconnectsIfReconnectPolicyAllowsIt() {
        let didCloseExpectation = expectation(description: "connection closed")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: TestReconnectPolicy(), logger: PrintLogger())

        var error: Error? = SignalRError.invalidOperation(message: "error")
        delegate.connectionDidOpenHandler = { connection in
            testConnection.delegate?.connectionDidClose(error: error)
            error = nil
        }

        delegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        reconnectableConnection.delegate = delegate
        reconnectableConnection.start()

        waitForExpectations(timeout: 5000 /*seconds*/)
    }

    class TestReconnectPolicy: ReconnectPolicy {
        func nextAttemptInterval() -> DispatchTimeInterval {
            return DispatchTimeInterval.milliseconds(50)
        }
    }

    class TestConnection: Connection {
        var delegate: ConnectionDelegate?

        var connectionId: String?

        func start() {
            delegate?.connectionDidOpen(connection: self)
        }

        func send(data: Data, sendDidComplete: (Error?) -> Void) {
            sendDidComplete(nil)
        }

        func stop(stopError: Error?) {
            delegate?.connectionDidClose(error: stopError)
        }
    }
}
