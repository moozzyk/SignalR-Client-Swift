//
//  HubConnectionExtensionsTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 6/11/19.
//

import XCTest
@testable import SignalRClient

class HubConnectionExtensionsTests: XCTestCase {
    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_0arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeNoArgs", resultType: Bool.self) { result, error in
                XCTAssertTrue(result!)
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: {
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_1arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs1", 42, resultType: Bool.self) { result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (number: Int) in
            XCTAssertEqual(42, number)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_2arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs2", "a", 2, resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_3arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs3", "a", 2, "c", resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_4arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs4", "a", 2, "c", 4, resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_5arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.invoke(method: "InvokeManyArgs5", "a", 2, "c", 4, arg5, resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_6arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.invoke(method: "InvokeManyArgs6", "a", 2, "c", 4, arg5, 6, resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_7arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.invoke(method: "InvokeManyArgs7", "a", 2, "c", 4, arg5, 6, "g", resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int, arg7: String) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            XCTAssertEqual("g", arg7)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericInvokeMethod_8arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.invoke(method: "InvokeManyArgs8", "a", 2, "c", 4, arg5, 6, "g", true, resultType: Bool.self) {result, error in
                XCTAssertNil(error)
                XCTAssertTrue(result!)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int, arg7: String, arg8: Bool) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            XCTAssertEqual("g", arg7)
            XCTAssertTrue(arg8)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_0arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.send(method: "InvokeNoArgs") { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: {
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_1arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.send(method: "InvokeManyArgs1", 42) { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (number: Int) in
            XCTAssertEqual(42, number)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_2arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.send(method: "InvokeManyArgs2", "a", 2) { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_3arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.send(method: "InvokeManyArgs3", "a", 2, "c") { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_4arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.send(method: "InvokeManyArgs4", "a", 2, "c", 4) { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_5arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.send(method: "InvokeManyArgs5", "a", 2, "c", 4, arg5) { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_6arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.send(method: "InvokeManyArgs6", "a", 2, "c", 4, arg5, 6) { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_7arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.send(method: "InvokeManyArgs7", "a", 2, "c", 4, arg5, 6, "g") { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int, arg7: String) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            XCTAssertEqual("g", arg7)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatServerHubMethodCanBeInvokedWithGenericSendMethod_8arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didSendComplete = expectation(description: "send invocation complete")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.send(method: "InvokeManyArgs8", "a", 2, "c", 4, arg5, 6, "g", true) { error in
                XCTAssertNil(error)
                didSendComplete.fulfill()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int, arg7: String, arg8: Bool) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            XCTAssertEqual("g", arg7)
            XCTAssertTrue(arg8)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_0arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeNoArgs") { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: {
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_1arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs1", 42) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (number: Int) in
            XCTAssertEqual(42, number)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_2arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs2", 42, 84) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: Int, arg2: Int) in
            XCTAssertEqual(42, arg1)
            XCTAssertEqual(84, arg2)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_3arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs3", 42, 84, 126) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: Int, arg2: Int, arg3: Int) in
            XCTAssertEqual(42, arg1)
            XCTAssertEqual(84, arg2)
            XCTAssertEqual(126, arg3)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_4arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs4", 42, 84, 126, 168) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: Int, arg2: Int, arg3: Int, arg4: Int) in
            XCTAssertEqual(42, arg1)
            XCTAssertEqual(84, arg2)
            XCTAssertEqual(126, arg3)
            XCTAssertEqual(168, arg4)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_5arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs5", "a", "b", "c", "d", "e") { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: String, arg3: String, arg4: String, arg5: String) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual("b", arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual("d", arg4)
            XCTAssertEqual("e", arg5)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_6arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs6", true, false, true, false, true, false) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: Bool, arg2: Bool, arg3: Bool, arg4: Bool, arg5: Bool, arg6: Bool) in
            XCTAssertTrue(arg1)
            XCTAssertFalse(arg2)
            XCTAssertTrue(arg3)
            XCTAssertFalse(arg4)
            XCTAssertTrue(arg5)
            XCTAssertFalse(arg6)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_7arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            hubConnection.invoke(method: "InvokeManyArgs7", 42, 84, 126, 168, 210, 252, 294) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: Int, arg2: Int, arg3: Int, arg4: Int, arg5: Int, arg6: Int, arg7: Int) in
            XCTAssertEqual(42, arg1)
            XCTAssertEqual(84, arg2)
            XCTAssertEqual(126, arg3)
            XCTAssertEqual(168, arg4)
            XCTAssertEqual(210, arg5)
            XCTAssertEqual(252, arg6)
            XCTAssertEqual(294, arg7)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatClientHubMethodRegisteredWithGenericOnMethodCanBeInvoked_8arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveInvocationResult = expectation(description: "received invocation result")
        let didInvokeClientMethod = expectation(description: "client method invoked")
        let didCloseExpectation = expectation(description: "connection closed")

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            let arg5: String? = nil
            hubConnection.invoke(method: "InvokeManyArgs8", "a", 2, "c", 4, arg5, 6, "g", true) { error in
                XCTAssertNil(error)
                didReceiveInvocationResult.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL)
            .withLogging(minLogLevel: .debug)
            .build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "ManyArgs", callback: { (arg1: String, arg2: Int, arg3: String, arg4: Int, arg5: String?, arg6: Int, arg7: String, arg8: Bool) in
            XCTAssertEqual("a", arg1)
            XCTAssertEqual(2, arg2)
            XCTAssertEqual("c", arg3)
            XCTAssertEqual(4, arg4)
            XCTAssertNil(arg5)
            XCTAssertEqual(6, arg6)
            XCTAssertEqual("g", arg7)
            XCTAssertTrue(arg8)
            didInvokeClientMethod.fulfill()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_0arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs0", streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_1arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs1", 1, streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_2arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs2", 1, 2, streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1, 2], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_3arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [String] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs3", "a", "b", "c", streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual(["a", "b", "c"], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_4arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [String] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs4", "a", "b", "c", "d", streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual(["a", "b", "c", "d"], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_5arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs5", 1, 2, 3, 4, 5, streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1, 2, 3, 4, 5], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_6arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs6", 1, 2, 3, 4, 5, 6, streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1, 2, 3, 4, 5, 6], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_7arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs7", 1, 2, 3, 4, 5, 6, 7, streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1, 2, 3, 4, 5, 6, 7], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStreamingServerHubMethodCanBeInvokedWithGenericStreamMethod_8arg() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveStreamItems = expectation(description: "received stream items")
        let didCloseExpectation = expectation(description: "connection closed")
        var items: [Int] = []

        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnectionDelegate.connectionDidOpenHandler = { hubConnection in
            didOpenExpectation.fulfill()

            _ = hubConnection.stream(method: "StreamManyArgs8", 1, 2, 3, 4, 5, 6, 7, 8, streamItemReceived: { item in items.append(item!) }) { error in
                XCTAssertNil(error)
                XCTAssertEqual([1, 2, 3, 4, 5, 6, 7, 8], items)
                didReceiveStreamItems.fulfill()
                hubConnection.stop()
            }
        }

        hubConnectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let hubConnection = HubConnectionBuilder(url: TARGET_TESTHUB_URL).build()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }
}
