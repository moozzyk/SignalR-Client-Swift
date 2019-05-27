//
//  HubConnectionTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class HubConnectionTests: XCTestCase {

    func testThatOpeningHubConnectionFailsIfHandshakeFails() {
        // This test fails most of the times when running against SignalR Service - the webSocket is closed
        // before receiving any data. Occasionally when data is being received before close the data is correct.
        // This is a negative test so leaving as is for now.
        let didFailToOpenExpectation = expectation(description: "connection failed to open")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { _ in XCTFail() }
        hubConnectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpenExpectation.fulfill()
            switch (error as? SignalRError) {
            case .handshakeError(let errorMessage)?:
                XCTAssertEqual("The protocol 'fakeProtocol' is not supported.", errorMessage)
                break
            default:
                XCTFail()
                break
            }
        }
        hubConnectionDelegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
            XCTAssertNil(error)
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withLogging(minLogLevel: .debug)
            .withHubProtocol(hubProtocolFactory: {_ in HubProtocolFake()})
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatHubMethodCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let message = "Hello, World!"
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "Echo", arguments: [message], resultType: String.self) {result, error in
                XCTAssertNil(error)
                XCTAssertEqual(message, result)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatHubMethodWithHeterogenousArgumentsCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "Concatenate", arguments: ["This is number:", 42], resultType: String.self) {result, error in
                XCTAssertNil(error)
                XCTAssertEqual("This is number: 42", result)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }


    func testTestThatInvokingHubMethodRetunsErrorIfInvokedBeforeHandshakeReceived() {
        let didComplete = expectation(description: "test completed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.start()
        hubConnection.invoke(method: "x", arguments: [], resultType: String.self) {result, error in
            XCTAssertNotNil(error)
            XCTAssertEqual("\(SignalRError.invalidOperation(message: "Attempting to send data before connection has been started."))", "\(error!)")
            hubConnection.stop()
            didComplete.fulfill()
        }

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

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testTestThatInvokingVoidHubMethodRetunsErrorIfInvokedBeforeHandshakeReceived() {
        let didOpenExpectation = expectation(description: "connection opened")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            XCTAssertNotNil(hubConnection.connectionId)
            didOpenExpectation.fulfill()
            hubConnection.stop()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testTestThatCanGetConnectionId() {
        let didComplete = expectation(description: "test completed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.start()
        hubConnection.invoke(method: "x", arguments: []) {error in
            XCTAssertNotNil(error)
            XCTAssertEqual("\(SignalRError.invalidOperation(message: "Attempting to send data before connection has been started."))", "\(error!)")
            hubConnection.stop()
            didComplete.fulfill()
        }

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatExceptionsInHubMethodsAreTurnedIntoErrors() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "ErrorMethod", arguments: [], resultType: String.self, invocationDidComplete: { result, error in
                XCTAssertNotNil(error)

                switch (error as! SignalRError) {
                case .hubInvocationError(let errorMessage):
                    XCTAssertEqual("An unexpected error occurred invoking 'ErrorMethod' on the server. InvalidOperationException: Error occurred.", errorMessage)
                    break
                default:
                    XCTFail()
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

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatPendingInvocationsAreCancelledWhenConnectionIsClosed() {
        let invocationCancelledExpectation = expectation(description: "invocation cancelled")

        let testConnection = TestConnection()
        let logger = PrintLogger()
        let hubConnection = HubConnection(connection: testConnection, hubProtocol: JSONHubProtocol(logger: logger), logger: logger)
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            hubConnection.invoke(method: "TestMethod", arguments: [], invocationDidComplete: { error in
                XCTAssertNotNil(error)

                switch (error as! SignalRError) {
                case .hubInvocationCancelled:
                    invocationCancelledExpectation.fulfill()
                    break
                default:
                    XCTFail()
                    break
                }
            })

            hubConnection.stop()
        }

        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatPendingInvocationsAreAbortedWhenConnectionIsClosedWithError() {
        let invocationCancelledExpectation = expectation(description: "invocation cancelled")
        let testError = SignalRError.invalidOperation(message: "testError")

        let testConnection = TestConnection()
        let hubConnection = HubConnection(connection: testConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnection.delegate = hubConnectionDelegate
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            hubConnection.invoke(method: "TestMethod", arguments: [], invocationDidComplete: { error in
                switch (error as! SignalRError) {
                case .invalidOperation(let errorMessage):
                    XCTAssertEqual("testError", errorMessage)
                    break
                default:
                    XCTFail()
                    break
                }
                invocationCancelledExpectation.fulfill()
            })
            testConnection.delegate?.connectionDidClose(error: testError)
        }

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingHubMethodCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamNumbers", arguments: [10, 1], itemType: Int.self, streamItemReceived: { item in items.append(item!) }, invocationDidComplete: { error in
                XCTAssertNil(error)
                XCTAssertEqual([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testTestThatInvokingStreamingMethodRetunsErrorIfInvokedBeforeHandshakeReceived() {
        let didComplete = expectation(description: "test completed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.start()
        _ = hubConnection.stream(method: "StreamNumbers", arguments: [], itemType: Int.self, streamItemReceived: {_ in }, invocationDidComplete: {error in
            XCTAssertNotNil(error)
            XCTAssertEqual("\(SignalRError.invalidOperation(message: "Attempting to send data before connection has been started."))", "\(error!)")
            hubConnection.stop()
            didComplete.fulfill()
        })

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatExceptionsInHubStreamingMethodsCloseStreamWithError() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationError = expectation(description: "received invocation error")
        let didCloseExpectation = expectation(description: "connection closed")

        var receivedItems: [String?] = []
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "ErrorStreamMethod", arguments: [], itemType: String.self, streamItemReceived: { item in receivedItems.append(item)} , invocationDidComplete: { error in
                XCTAssertNotNil(error)

                switch (error as! SignalRError) {
                case .hubInvocationError(let errorMessage):
                    XCTAssertEqual("An error occurred on the server while streaming results. InvalidOperationException: Error occurred while streaming.", errorMessage)
                    break
                default:
                    XCTFail()
                    break
                }

                XCTAssertEqual(2, receivedItems.count)
                XCTAssertEqual("abc", receivedItems[0])
                XCTAssertEqual(nil, receivedItems[1])
                didReceiveInvocationError.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatExceptionsWhileProcessingStreamItemCloseStreamWithError() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationError = expectation(description: "received invocation error")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamNumbers", arguments: [5, 5], itemType: UUID.self, streamItemReceived: { item in XCTFail() } , invocationDidComplete: { error in
                XCTAssertNotNil(error)
                switch (error as! SignalRError) {
                case .serializationError:
                    break
                default:
                    XCTFail()
                    break
                }

                didReceiveInvocationError.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatPendingStreamInvocationsAreCancelledWhenConnectionIsClosed() {
        let invocationCancelledExpectation = expectation(description: "invocation cancelled")

        let testConnection = TestConnection()
        let hubConnection = HubConnection(connection: testConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = {hubConnection in
            _ = hubConnection.stream(method: "StreamNumbers", arguments: [5, 100], itemType: Int.self, streamItemReceived: { item in }, invocationDidComplete: { error in
                XCTAssertNotNil(error)

                switch (error as! SignalRError) {
                case .hubInvocationCancelled:
                    invocationCancelledExpectation.fulfill()
                    break
                default:
                    XCTFail()
                    break
                }
            })
            hubConnection.stop()
        }
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatPendingStreamInvocationsAreAbortedWhenConnectionIsClosedWithError() {
        let invocationCancelledExpectation = expectation(description: "invocation cancelled")
        let testError = SignalRError.invalidOperation(message: "testError")

        let testConnection = TestConnection()
        let hubConnection = HubConnection(connection: testConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = {hubConnection in
            _ = hubConnection.stream(method: "StreamNumbers", arguments: [5, 100], itemType: Int.self, streamItemReceived: { item in }, invocationDidComplete: { error in
                switch (error as! SignalRError) {
                case .invalidOperation(let errorMessage):
                    XCTAssertEqual("testError", errorMessage)
                    break
                default:
                    XCTFail()
                    break
                }
                invocationCancelledExpectation.fulfill()
            })
            testConnection.delegate?.connectionDidClose(error: testError)
        }
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatCanCancelStreamingInvocations() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        var lastItem = -1
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            var streamHandle: StreamHandle? = nil
            streamHandle = hubConnection.stream(method: "StreamNumbers", arguments: [1000, 1], itemType: Int.self, streamItemReceived: { item in
                lastItem = item!
                if item == 42 {
                    hubConnection.cancelStreamInvocation(streamHandle: streamHandle!, cancelDidFail: { _ in XCTFail() })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        hubConnection.stop()
                    }
                }
            }, invocationDidComplete: { _ in XCTFail() })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            XCTAssert(lastItem < 50)
            didCloseExpectation.fulfill()
        }

        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatCancellingStreamingInvocationSendsCancelStreamMessage() {
        var messages: [Data] = []

        let testConnection = TestConnection()
        testConnection.sendDelegate = { data, sendDidComplete in
            messages.append(data)
            sendDidComplete(nil)
        }

        let hubConnection = HubConnection(connection: testConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnection.delegate = hubConnectionDelegate
        hubConnectionDelegate.connectionDidOpenHandler = {hubConnection in
            let streamHandle = hubConnection.stream(method: "TestStream", arguments: [], itemType: Int.self,
                                                    streamItemReceived: { _ in XCTFail() },
                                                    invocationDidComplete: { _ in XCTFail() })
            hubConnection.cancelStreamInvocation(streamHandle: streamHandle, cancelDidFail: { _ in XCTFail() })

            hubConnection.stop()

            // 3 messages: protocol negotation/handshake, stream method invocation, stream method cancellation
            XCTAssertEqual(3, messages.count)
            let methodCancellationJson = try! JSONSerialization.jsonObject(with: messages.last!.split(separator: 0x1e).first!) as! [String: Any]
            XCTAssertEqual(2, methodCancellationJson.count)
            XCTAssertEqual(5, methodCancellationJson["type"] as! Int)
            XCTAssertEqual("1", methodCancellationJson["invocationId"] as! String)
        }
        hubConnection.start()
    }

    func testThatCallbackInvokedIfSendingCancellationMessageFailed() {
        let cancelDidFailExpectation = expectation(description: "cancelDidFail invoked")

        let testConnection = TestConnection()
        testConnection.sendDelegate = { data, sendDidComplete in
            let msg = String(data: data, encoding: .utf8)!
            sendDidComplete(msg.contains("\"type\":5") ? SignalRError.invalidOperation(message: "test") : nil)
        }

        let hubConnection = HubConnection(connection: testConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = {hubConnection in
            let streamHandle = hubConnection.stream(method: "TestStream", arguments: [], itemType: Int.self,
                                                    streamItemReceived: { _ in XCTFail() },
                                                    invocationDidComplete: { _ in XCTFail() })
            hubConnection.cancelStreamInvocation(streamHandle: streamHandle, cancelDidFail: { error in
                switch (error as! SignalRError) {
                case .invalidOperation(let errorMessage):
                    XCTAssertEqual("test", errorMessage)
                    break
                default:
                    XCTFail()
                    break
                }
                hubConnection.stop()
                cancelDidFailExpectation.fulfill()
            })
        }
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testTestThatCancellingStreamingInvocationRetunsErrorIfInvokedBeforeHandshakeReceived() {
        let didComplete = expectation(description: "test completed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.start()
        hubConnection.cancelStreamInvocation(streamHandle: StreamHandle(invocationId: "123")) {error in
            XCTAssertEqual("\(SignalRError.invalidOperation(message: "Attempting to send data before connection has been started."))", "\(error)")
            hubConnection.stop()
            didComplete.fulfill()
        }

        waitForExpectations(timeout: 5 /*seconds*/)
    }
    
    func testTestThatCancellingStreamingInvocationWithInvalidStreamHandleRetunsErrorIfInvokedBeforeHandshakeReceived() {
        let didComplete = expectation(description: "test completed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = {hubConnection in
            hubConnection.cancelStreamInvocation(streamHandle: StreamHandle(invocationId: "")) {error in
                XCTAssertEqual("\(SignalRError.invalidOperation(message: "Invalid stream handle."))", "\(error)")
                hubConnection.stop()
                didComplete.fulfill()
            }
        }
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientMethodsCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeGetNumber", arguments: [42], invocationDidComplete: { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "GetNumber", callback: { argumentExtractor in
            XCTAssertTrue(argumentExtractor.hasMoreArgs())
            XCTAssertEqual(42, try argumentExtractor.getArgument(type: Int.self))
            XCTAssertFalse(argumentExtractor.hasMoreArgs())
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientMethodsCanBeInvokedMultipleArgs() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs", arguments: [[42, 43]], invocationDidComplete: { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { argumentExtractor in
            XCTAssertTrue(argumentExtractor.hasMoreArgs())
            XCTAssertEqual(42, try argumentExtractor.getArgument(type: Int.self))
            XCTAssertTrue(argumentExtractor.hasMoreArgs())
            XCTAssertEqual(43, try argumentExtractor.getArgument(type: Int.self))
            XCTAssertFalse(argumentExtractor.hasMoreArgs())
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }


    func testThatClientMethodsCanBeOverwritten() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeGetNumber", arguments: [42], invocationDidComplete: { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate

        hubConnection.on(method: "GetNumber", callback: { argumentExtractor in
            XCTFail("Should not be invoked")
        })

        hubConnection.on(method: "GetNumber", callback: { argumentExtractor in
            XCTAssertNotNil(argumentExtractor)
            XCTAssertEqual(42, try argumentExtractor.getArgument(type: Int.self))
            XCTAssertFalse(argumentExtractor.hasMoreArgs())
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientMethodsCanBeInvokedWithTypedStructuralArgument() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let person = User(firstName: "Jerzy", lastName: "Meteor", age: 34, height: 179.0, sex: Sex.Male)
            hubConnection.invoke(method: "InvokeGetPerson", arguments: [person], invocationDidComplete: { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withJSONHubProtocol()
            .build()

        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "GetPerson", callback: { argumentExtractor in
            XCTAssertNotNil(argumentExtractor)
            let person = try argumentExtractor.getArgument(type: User.self)
            XCTAssertFalse(argumentExtractor.hasMoreArgs())
            XCTAssertEqual("Jerzy", person.firstName)
            XCTAssertEqual("Meteor", person.lastName)
            XCTAssertEqual(34, person.age)
            XCTAssertEqual(179.0, person.height)
            XCTAssertEqual(Sex.Male, person.sex)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendInvokesMethodsOnServer() {
        let didOpenExpectation = expectation(description: "connection opened")
        let sendCompletedExpectation = expectation(description: "send completed")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.send(method: "InvokeGetNumber", arguments: [42], sendDidComplete: { error in
                XCTAssertNil(error)
                sendCompletedExpectation.fulfill()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "GetNumber", callback: { argumentExtractor in
            XCTAssertNotNil(argumentExtractor)
            XCTAssertEqual(42, try argumentExtractor.getArgument(type: Int.self))
            XCTAssertFalse(argumentExtractor.hasMoreArgs())
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testTestThatSendRetunsErrorIfInvokedBeforeHandshakeReceived() {
        let didComplete = expectation(description: "test completed")

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!).build()
        hubConnection.start()
        hubConnection.send(method: "x", arguments: []) {error in
            XCTAssertNotNil(error)
            XCTAssertEqual("\(SignalRError.invalidOperation(message: "Attempting to send data before connection has been started."))", "\(error!)")
            hubConnection.stop()
            didComplete.fulfill()
        }

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    enum Sex: Int, Codable {
        case Male
        case Female
    }

    struct User: Codable {
        public let firstName: String
        let lastName: String
        let age: Int?
        let height: Double?
        let sex: Sex?
    }

    func testThatHubMethodUsingComplexTypesCanBeInvoked() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let input = [User(firstName: "Klara", lastName: "Smetana", age: nil, height: 166.5, sex: Sex.Female),
                         User(firstName: "Jerzy", lastName: "Meteor", age: 34, height: 179.0, sex: Sex.Male)]

            hubConnection.invoke(method: "SortByName", arguments: [input], resultType: [User].self, invocationDidComplete: { people, error in
                XCTAssertNil(error)
                XCTAssertNotNil(people)
                XCTAssertEqual(2, people!.count)

                XCTAssertEqual("Jerzy", people![0].firstName)
                XCTAssertEqual("Meteor", people![0].lastName)
                XCTAssertEqual(34, people![0].age)
                XCTAssertEqual(179.0, people![0].height)
                XCTAssertEqual(Sex.Male, people![0].sex)

                XCTAssertEqual("Klara", people![1].firstName)
                XCTAssertEqual("Smetana", people![1].lastName)
                XCTAssertNil(people![1].age)
                XCTAssertEqual(166.5, people![1].height)
                XCTAssertEqual(Sex.Female, people![1].sex)

                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            })
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withJSONHubProtocol()
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatHubConnectionSendsHeaders() {
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            hubConnection.invoke(method: "GetHeader", arguments: ["TestHeader"], resultType: String.self, invocationDidComplete: { result, error in
                XCTAssertNil(error)
                XCTAssertEqual("header", result)
                hubConnection.stop()
            })
        }

        let didCloseExpectation = expectation(description: "connection closed")
        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.headers["TestHeader"] = "header"
            }
            .build()

        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatHubConnectionSendsAuthToken() {
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            hubConnection.invoke(method: "GetHeader", arguments: ["Authorization"], resultType: String.self, invocationDidComplete: { result, error in
                XCTAssertNil(error)
                XCTAssertEqual("Bearer abc", result)
                hubConnection.stop()
            })
        }

        let didCloseExpectation = expectation(description: "connection closed")
        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: URL(string: "\(BASE_URL)/testhub")!)
            .withHttpConnectionOptions() { httpConnectionOptions in
                httpConnectionOptions.accessTokenProvider = { return "abc" }
            }
            .build()

        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStopDoesNotPassStopErrorToUnderlyingConnection() {
        class FakeHttpConnection: HttpConnection {
            var stopCalled: Bool = false

            override func stop(stopError: Error?) {
                XCTAssertNil(stopError)
                stopCalled = true
            }
        }

        let fakeConnection = FakeHttpConnection(url: URL(string: "http://fakeuri.org")!)
        let hubConnection = HubConnection(connection: fakeConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        hubConnection.stop()
        XCTAssertTrue(fakeConnection.stopCalled)
    }

    func testThatHubConnectionClosesConnectionUponReceivingCloseMessage() {
        class FakeHttpConnection: HttpConnection {
            var stopError: Error?

            override func start() {
                delegate?.connectionDidOpen(connection: self)
            }

            override func stop(stopError: Error?) {
                self.stopError = stopError
            }
        }

        let fakeConnection = FakeHttpConnection(url: URL(string: "http://fakeuri.org")!)
        let hubConnection = HubConnection(connection: fakeConnection, hubProtocol: JSONHubProtocol(logger: NullLogger()))
        hubConnection.start()
        let payload = "{}\u{1e}{ \"type\": 7, \"error\": \"Server Error\" }\u{1e}"
        fakeConnection.delegate.connectionDidReceiveData(connection: fakeConnection, data: payload.data(using: .utf8)!)
        XCTAssertEqual(String(describing: SignalRError.serverClose(message: "Server Error")), String(describing: fakeConnection.stopError!))
    }
}

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

class TestConnection: Connection {
    var connectionId: String?

    var delegate: ConnectionDelegate!
    var sendDelegate: ((_ data: Data, _ sendDidComplete: (_ error: Error?) -> Void) -> Void)?

    func start() {
        connectionId = "00000000-0000-0000-C000-000000000046"
        delegate?.connectionDidOpen(connection: self)
        delegate?.connectionDidReceiveData(connection: self, data: "{}\u{1e}".data(using: .utf8)!)
    }

    func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
        sendDelegate?(data, sendDidComplete)
    }

    func stop(stopError: Error? = nil) -> Void {
        connectionId = nil
        delegate?.connectionDidClose(error: stopError)
    }
}

class ArgumentExtractorTests: XCTestCase {
    func testThatArgumentExtractorCallsIntoClientInvocationMessage() {
        let payload = "{ \"type\": 1, \"target\": \"method\", \"arguments\": [42, \"abc\"] }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! ClientInvocationMessage
        let argumentExtractor = ArgumentExtractor(clientInvocationMessage: msg)
        XCTAssertTrue(argumentExtractor.hasMoreArgs())
        XCTAssertEqual(42, try! argumentExtractor.getArgument(type: Int.self))
        XCTAssertTrue(argumentExtractor.hasMoreArgs())
        XCTAssertEqual("abc", try! argumentExtractor.getArgument(type: String.self))
        XCTAssertFalse(argumentExtractor.hasMoreArgs())
    }
}
