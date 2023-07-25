//
//  ReconnectableConnectionTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 11/23/19.
//
import XCTest
@testable import SignalRClient

class ReconnectableConnectionTests: XCTestCase {
    private let callbackQueue = DispatchQueue(label: "SignalR.test.connection.callbackQueue")

    public func testThatConnectionDoesNotReconnectIfReconnectPolicyReturnsNever() {
        let didCloseExpectation = expectation(description: "connection closed")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: NoReconnectPolicy(), callbackQueue: callbackQueue, logger: PrintLogger())

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
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), callbackQueue: callbackQueue, logger: PrintLogger())

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
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10), .milliseconds(10), .milliseconds(10)]), callbackQueue: callbackQueue, logger: PrintLogger())

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
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), callbackQueue: callbackQueue, logger: PrintLogger())

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

    public func testThatSendingDuringReconnectDoesNotCauseDeadlock() {
        let didCloseExpectation = expectation(description: "connection closed")
        let sendDidFail = expectation(description: "send failed")

        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), callbackQueue: callbackQueue, logger: PrintLogger())

        let tmpQueue = DispatchQueue(label: "SignalR.test.temp.queue")

        delegate.connectionDidOpenHandler = { _ in
            testConnection.delegate?.connectionDidClose(error: SignalRError.invalidOperation(message: "forcing reconnect"))
            tmpQueue.async {
                reconnectableConnection.send(data: "Should fail".data(using: .utf8)!) { error in
                    tmpQueue.sync {
                        XCTAssertNotNil(error)
                        XCTAssertEqual(String(describing: error!), String(describing: SignalRError.connectionIsReconnecting))
                        reconnectableConnection.stop(stopError: nil)
                        sendDidFail.fulfill()
                    }
                }
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
            let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), callbackQueue: callbackQueue, logger: PrintLogger())
            XCTAssertEqual(inherentKeepAlive, reconnectableConnection.inherentKeepAlive)
        }
    }

    public func testReconnectEventsDontFireIfConnectionNeverConnected() {
        let connectionDidFailToOpenExpectation = expectation(description: "connectionDidFailToOpen")
        let connectionDidOpenExpectation = expectation(description: "connectionDidOpen")
        connectionDidOpenExpectation.isInverted = true
        let connectionDidCloseExpectation = expectation(description: "connectionDidClose")
        connectionDidCloseExpectation.isInverted = true
        let connectionWillReconnectExpectation = expectation(description: "connectionWillReconnect")
        connectionWillReconnectExpectation.isInverted = true
        let connectionDidReconnectExpectation = expectation(description: "connectionDidReconnect")
        connectionDidReconnectExpectation.isInverted = true

        let testConnection = TestConnection()
        testConnection.openError = SignalRError.invalidNegotiationResponse(message: "Negotiation failed")

        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: DefaultReconnectPolicy(retryIntervals: [.milliseconds(10)]), callbackQueue: callbackQueue, logger: PrintLogger())

        delegate.connectionDidFailToOpenHandler = { error in
            connectionDidFailToOpenExpectation.fulfill()
        }

        delegate.connectionDidOpenHandler = { connection in
            connectionDidOpenExpectation.fulfill()
        }

        delegate.connectionDidCloseHandler = { error in
            connectionDidCloseExpectation.fulfill()
        }

        delegate.connectionWillReconnectHandler = { error in
            connectionWillReconnectExpectation.fulfill()
        }

        delegate.connectionDidReconnectHandler = {
            connectionDidReconnectExpectation.fulfill()
        }

        reconnectableConnection.delegate = delegate
        reconnectableConnection.start()

        waitForExpectations(timeout: 2 /*seconds*/)
    }
    
    public func testReconnectableConnectionIgnoreStopRequestWhenDisconnected() {
        
        var isConnectionOpen = false
        
        let testConnection = TestConnection()
        let delegate = TestConnectionDelegate()
        let reconnectableConnection = ReconnectableConnection(connectionFactory: {return testConnection}, reconnectPolicy: NoReconnectPolicy(), callbackQueue: callbackQueue, logger: PrintLogger())
        reconnectableConnection.delegate = delegate
        
        delegate.connectionDidOpenHandler = { connection in
            isConnectionOpen = true
        }
        
        delegate.connectionDidCloseHandler = { connection in
            isConnectionOpen = false
        }
        
        reconnectableConnection.start()
        XCTAssertTrue(isConnectionOpen)
        
        reconnectableConnection.stop(stopError: nil)
        XCTAssertTrue(!isConnectionOpen)
        
        // stop the connection while it is disconnected
        reconnectableConnection.stop(stopError: nil)
        XCTAssertTrue(!isConnectionOpen)
        
        reconnectableConnection.start()
        XCTAssertTrue(isConnectionOpen)
    }
    
    class TestConnection: Connection {
        var delegate: ConnectionDelegate?
        var openError: Error?
        
        var connectionId: String?
        var inherentKeepAlive = false
        var isClosed: Bool = false
        
        func start() {
            if let e = openError {
                delegate?.connectionDidFailToOpen(error: e)
            } else {
                delegate?.connectionDidOpen(connection: self)
                self.isClosed = false
            }
        }
        
        func send(data: Data, sendDidComplete: (Error?) -> Void) {
            sendDidComplete(nil)
        }
        
        func stop(stopError: Error?) {
            // Recreating the logic as in HTTPConnection. (the delegate method would only be called when the connection state changes to stopped. Therefore the state transition of ReconnectableConnection to disconnected will not be executed
            guard !self.isClosed else { return }
            self.isClosed = true
            delegate?.connectionDidClose(error: stopError)
        }
        
    }
}
