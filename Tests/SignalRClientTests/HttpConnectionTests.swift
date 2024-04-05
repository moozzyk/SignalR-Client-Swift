//
//  ConnectionTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class HttpConnectionTests: XCTestCase {

    func testThatConnectionCanSendReceiveMessages() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveMessageExpectation = expectation(description: "message received")
        let didCloseExpectation = expectation(description: "connection closed")

        let message = "Hello, World!"
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            connection.send(data: message.data(using: .utf8)!) { error in
                if let e = error {
                    print(e)
                }
            }
            didOpenExpectation.fulfill()
        }

        connectionDelegate.connectionDidReceiveDataHandler = { connection, data in
            XCTAssertEqual(message, String(data: data, encoding: .utf8))
            didReceiveMessageExpectation.fulfill()
            connection.stop(stopError: nil)
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let connection = HttpConnection(url: TARGET_ECHO_URL)
        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    /// Only expected to pass if the server ONLY supports WebSockets.
    @available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testThatConnectionCanSendReceiveMessagesWithSkipNegotiation() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didReceiveMessageExpectation = expectation(description: "message received")
        let didCloseExpectation = expectation(description: "connection closed")

        let message = "Hello, World!"
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            connection.send(data: message.data(using: .utf8)!) { error in
                if let e = error {
                    print(e)
                }
            }
            didOpenExpectation.fulfill()
        }

        connectionDelegate.connectionDidReceiveDataHandler = { connection, data in
            XCTAssertEqual(message, String(data: data, encoding: .utf8))
            didReceiveMessageExpectation.fulfill()
            connection.stop(stopError: nil)
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(error)
            didCloseExpectation.fulfill()
        }

        let httpClient = TestHttpClient(postHandler: { _ in
            XCTFail()
            return (HttpResponse(statusCode: 500, contents: nil), nil)
        })
        let options = HttpConnectionOptions()
        options.skipNegotiation = true
        options.httpClientFactory = { options in httpClient }
        let connection = HttpConnection(url: ECHO_WEBSOCKETS_URL, options: options)
        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatOpeningConnectionFailsIfConnectionNotInInitialState() {
        let didFailToOpenExpectation = expectation(description: "connection failed to open")
        let didCloseExpectation = expectation(description: "connection closed")

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            connection.stop(stopError: nil)
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
        }

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpenExpectation.fulfill()
        }

        let connection = HttpConnection(url: TARGET_ECHO_URL)
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

        let connection = HttpConnection(url: URL(string: "http://localhost:1000/echo")!)
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

        let connection = HttpConnection(url: URL(string: "\(BASE_URL)/throw")!)
        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedBeforeStartingConnection() {
        let sendFailedExpectation = expectation(description: "send fails expectation")
        let connection = HttpConnection(url: URL(string: "http://fakeuri.org")!)

        connection.send(data: "".data(using: .utf8)!) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error!), String(describing: SignalRError.invalidState))
            sendFailedExpectation.fulfill()
        }

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedAfterConnectionFailedToStart() {
        let sendFailedExpectation = expectation(description: "send failed")
        let connection = HttpConnection(url: URL(string: "\(BASE_URL)/throw")!)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
                connection.send(data: "".data(using: .utf8)!) { sendError in
                    XCTAssertNotNil(sendError)
                    XCTAssertEqual(String(describing: sendError!), String(describing: SignalRError.invalidState))
                    sendFailedExpectation.fulfill()
                }
            }

        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedAfterConnectionClosed() {
        let sendFailedExpectation = expectation(description: "send failed")

        let testTransport = TestTransport()
        let transportFactory = TestTransportFactory(testTransport)
        let connection = HttpConnection(url: TARGET_ECHO_URL, options: HttpConnectionOptions(), transportFactory: transportFactory, logger: PrintLogger())
        let connectionDelegate = TestConnectionDelegate()

        connectionDelegate.connectionDidOpenHandler = { connection in
            testTransport.delegate?.transportDidClose(nil)
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            connection.send(data: "".data(using: .utf8)!) { sendError in
                XCTAssertNotNil(sendError)
                XCTAssertEqual(String(describing: sendError!), String(describing: SignalRError.invalidState))
                sendFailedExpectation.fulfill()
            }
        }

        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatSendThrowsIfInvokedAfterConnectionStopped() {
        let sendFailedExpectation = expectation(description: "send failed")

        let connection = HttpConnection(url: TARGET_ECHO_URL)
        connection.start()
        connection.stop()

        connection.send(data: "".data(using: .utf8)!) { sendError in
            XCTAssertNotNil(sendError)
            XCTAssertEqual(String(describing: sendError!), String(describing: SignalRError.invalidState))
            sendFailedExpectation.fulfill()
        }

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatCannotStartConnectionAfterItWasStopped() {
        let didOpenExpectation = expectation(description: "connection opened")
        let didCloseExpectation = expectation(description: "connection closed")
        let didFailToOpen = expectation(description: "connection failed to open")

        let connection = HttpConnection(url: TARGET_ECHO_URL)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            connection.stop(stopError: nil)
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

        let connection = HttpConnection(url: TARGET_ECHO_URL)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            connection.stop(stopError: nil)
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

        let connection = HttpConnection(url: TARGET_ECHO_URL)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            didOpenExpectation.fulfill()
            connection.start()
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

    func testThatCanStopConnectionThatIsStarting() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let connection = HttpConnection(url: TARGET_ECHO_URL, options: HttpConnectionOptions(), logger: PrintLogger())
        let connectionDelegate = TestConnectionDelegate()

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpenExpectation.fulfill()
            XCTAssertNotNil(error)
            XCTAssertEqual(String(describing: error), String(describing: SignalRError.connectionIsBeingClosed))
        }

        connection.delegate = connectionDelegate
        connection.start()
        connection.stop()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatCanStopConnectionThatFailsNegotiation() {
        let didFailToOpen = expectation(description: "connection did fail to open")
        let didCloseExpectation = expectation(description: "connection closed")

        let connection = HttpConnection(url: URL(string: "\(BASE_URL)")!)
        let connectionDelegate = TestConnectionDelegate()

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            didFailToOpen.fulfill()
            XCTAssertNotNil(error)
        }

        connectionDelegate.connectionDidCloseHandler = { error in
            didCloseExpectation.fulfill()
            XCTAssertNil(error)
        }

        connection.delegate = connectionDelegate
        connection.start()
        connection.stop()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionStoppedWithErrorPassesErrorToDelegate() {
        enum testError: Error {
            case stopError
        }

        let didCloseExpectation = expectation(description: "connection closed")

        let connection = HttpConnection(url: TARGET_ECHO_URL, options: HttpConnectionOptions(), logger: PrintLogger())

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertEqual(testError.stopError, error as! testError)
            didCloseExpectation.fulfill()
        }
        connectionDelegate.connectionDidOpenHandler = { _ in
            connection.stop(stopError: testError.stopError)
        }

        connection.delegate = connectionDelegate
        connection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionFailsToOpenIfNegotiationFails() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let startError = SignalRError.invalidOperation(message: "fail")
        let httpClient = TestHttpClient(postHandler: { _ in (nil, startError) })
        let httpConnectionOptions = HttpConnectionOptions()
        httpConnectionOptions.httpClientFactory = { options in httpClient }
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org")!, options: httpConnectionOptions)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(startError)", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionFailsToOpenIfNegotiateResponseNil() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let httpClient = TestHttpClient(postHandler: { _ in (nil, nil) })
        let httpConnectionOptions = HttpConnectionOptions()
        httpConnectionOptions.httpClientFactory = { options in httpClient }
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org")!, options: httpConnectionOptions)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(SignalRError.invalidNegotiationResponse(message: "negotiate returned nil httpResponse."))", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionFailsToOpenIfNegotiateStatusNotOK() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let httpClient = TestHttpClient(postHandler: { _ in (HttpResponse(statusCode: 500, contents: nil), nil) })
        let httpConnectionOptions = HttpConnectionOptions()
        httpConnectionOptions.httpClientFactory = { options in httpClient }
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org")!, options: httpConnectionOptions)
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(SignalRError.webError(statusCode: 500))", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionFailsToOpenIfNegotiateResponseNotValid() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let httpClient = TestHttpClient(postHandler: { _ in (HttpResponse(statusCode: 200, contents: "{}".data(using: .utf8)!), nil) })
        let httpConnectionOptions = HttpConnectionOptions()
        httpConnectionOptions.httpClientFactory = { options in httpClient }
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org")!, options: httpConnectionOptions, logger: PrintLogger())
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(SignalRError.invalidNegotiationResponse(message: "connectionId property not found or invalid"))", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionFailsToOpenIfStopCalledDuringNegotiate() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let httpConnectionOptions = HttpConnectionOptions()
        let httpConnection = HttpConnection(url: URL(string:"\(BASE_URL)")!, options: httpConnectionOptions, logger: PrintLogger())
        let httpClient = TestHttpClient(postHandler: { _ in
            DispatchQueue.global().async {
                httpConnection.stop()
            }
            return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
        })
        httpConnectionOptions.httpClientFactory = { options in httpClient }

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(SignalRError.connectionIsBeingClosed)", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        connectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNotNil(error)
            XCTAssertTrue("\(error!)".contains("Code=-1011"))
            // This test is not deterministic and either of the handlers can be invoked
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatStoppingConnectionWhenTransportIsStartingDoesNotDeadlock() {
        class FakeTransport: Transport {
            var delegate: TransportDelegate?
            var httpConnection: Connection?

            let inherentKeepAlive = false

            func start(url: URL, options: HttpConnectionOptions) {
                DispatchQueue.global().async {
                    self.httpConnection!.stop(stopError: nil)
                }
                delegate?.transportDidOpen()
            }

            func send(data: Data, sendDidComplete: (Error?) -> Void) {
            }

            func close() {
                delegate?.transportDidClose(nil)
            }
        }

        let connectionDidCloseExpectation = expectation(description: "connection closed")

        let httpClient = TestHttpClient(postHandler: { _ in
            return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
        })
        let httpConnectionOptions = HttpConnectionOptions()
        httpConnectionOptions.httpClientFactory = { _ in httpClient }
        let transport = FakeTransport()

        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org")!, options: httpConnectionOptions, transportFactory: TestTransportFactory(transport), logger: PrintLogger())

        transport.httpConnection = httpConnection

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidCloseHandler = { _ in
            connectionDidCloseExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
        transport.httpConnection = nil
    }

    func testThatConnectionFailsToOpenIfStartingTheTransportFails() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let httpConnectionOptions = HttpConnectionOptions()
        let httpConnection = HttpConnection(url: ECHO_NOTRANSPORTS_URL, options: httpConnectionOptions, logger: PrintLogger())
        let httpClient = TestHttpClient(postHandler: { _ in
            return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
        })
        httpConnectionOptions.httpClientFactory = { options in httpClient }

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(SignalRError.webError(statusCode: 404))", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionFailsToOpenIfTransportNotAvailable() {
        let didFailToOpenExpectation = expectation(description: "connection did fail to open")

        let httpConnectionOptions = HttpConnectionOptions()
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org/")!, options: httpConnectionOptions, logger: PrintLogger())
        let httpClient = TestHttpClient(postHandler: { _ in
            let negotiatePayload = "{\"connectionId\":\"6baUtSEmluCoKvmUIqLUJw\",\"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\",\"negotiateVersion\":1,\"availableTransports\":[]}"
            return (HttpResponse(statusCode: 200, contents: negotiatePayload.data(using: .utf8)!), nil)
        })
        httpConnectionOptions.httpClientFactory = { options in httpClient }

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertEqual("\(SignalRError.noSupportedTransportAvailable)", "\(error)")
            didFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    private let negotiatePayload = "{\"connectionId\":\"6baUtSEmluCoKvmUIqLUJw\",\"connectionToken\": \"9AnFxsjXqnRuz4UBt2W8\",\"negotiateVersion\":1,\"availableTransports\":[{\"transport\":\"WebSockets\",\"transferFormats\":[\"Text\",\"Binary\"]},{\"transport\":\"ServerSentEvents\",\"transferFormats\":[\"Text\"]},{\"transport\":\"LongPolling\",\"transferFormats\":[\"Text\",\"Binary\"]}]}"

    private class TestTransportFactory: TransportFactory {
        let createTransport: () -> Transport

        init(_ createTransport: @escaping @autoclosure () -> Transport) {
            self.createTransport = createTransport
        }

        func createTransport(availableTransports: [TransportDescription]) throws -> Transport {
            return createTransport()
        }
    }

    func testThatConnectionFollowsRedirects() {
        let redirectionExpectation = expectation(description: "redirected")
        let connectionDidFailToOpenExpectation = expectation(description: "failedToOpen")

        let initialUrl = "http://fakeuri.org"

        let httpConnectionOptions = HttpConnectionOptions()
        let httpClient = TestHttpClient(postHandler: { url in
            if (url.absoluteString == initialUrl + "/negotiate?negotiateVersion=1") {
                let negotiatePayload = "{\"accessToken\":\"xyz\",\"url\":\"https://service/?abcdef\"}"
                return (HttpResponse(statusCode: 200, contents: negotiatePayload.data(using: .utf8)!), nil)
            }

            XCTAssertEqual("https://service/negotiate?abcdef", url.absoluteString)
            XCTAssertEqual("xyz", httpConnectionOptions.accessTokenProvider())

            redirectionExpectation.fulfill()
            return (HttpResponse(statusCode: 500, contents: nil), nil)
        })

        httpConnectionOptions.httpClientFactory = { options in httpClient }
        let httpConnection = HttpConnection(url: URL(string: initialUrl)!, options: httpConnectionOptions)

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { _ in
            connectionDidFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testConnectionPassesConnectionIdWhenStartingTransport() {
        class ConnectionIdTransport: TestTransport {
            override func start(url: URL, options: HttpConnectionOptions) {
                XCTAssertTrue(url.absoluteString.contains("?id=9AnFxsjXqnRuz4UBt2W8"))
                super.start(url: url, options: options)
            }
        }

        let connectionOpenedExpectation = expectation(description: "connection opened")
        let httpConnectionOptions = HttpConnectionOptions()
        let transport = ConnectionIdTransport()
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org/")!, options: httpConnectionOptions, transportFactory: TestTransportFactory(transport), logger: PrintLogger())
        let httpClient = TestHttpClient(postHandler: { _ in
            return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
        })
        httpConnectionOptions.httpClientFactory = { options in httpClient }

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            connectionOpenedExpectation.fulfill()
            connection.stop(stopError: nil)
        }

        httpConnection.delegate = connectionDelegate
        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionIdIsAvailableAfterStartAndClearedAfterStop() {
        let connectionIdSetExpectation = expectation(description: "connectionId set")
        let connectionIdClearedExpectation = expectation(description: "connectionId cleared")

        let httpConnectionOptions = HttpConnectionOptions()
        let transport = TestTransport()
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org/")!, options: httpConnectionOptions, transportFactory: TestTransportFactory(transport), logger: PrintLogger())
        let httpClient = TestHttpClient(postHandler: { _ in
            return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
        })
        httpConnectionOptions.httpClientFactory = { options in httpClient }
        
        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            XCTAssertEqual("6baUtSEmluCoKvmUIqLUJw", connection.connectionId)
            connectionIdSetExpectation.fulfill()
            httpConnection.stop();
        }
        connectionDelegate.connectionDidCloseHandler = { error in
            XCTAssertNil(httpConnection.connectionId)
            connectionIdClearedExpectation.fulfill()
        }
        
        httpConnection.delegate = connectionDelegate
        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatConnectionIdNotSetIfTransportFailsToOpen() {
        class UnopenableTransport: TestTransport {
            override func start(url: URL, options: HttpConnectionOptions) {
                delegate?.transportDidClose(SignalRError.invalidOperation(message: "testError"))
            }
        }

        let connectionIdNotSetExpectation = expectation(description: "connectionId set")

        let httpConnectionOptions = HttpConnectionOptions()
        let transport = UnopenableTransport()
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org/")!, options: httpConnectionOptions, transportFactory: TestTransportFactory(transport), logger: PrintLogger())
        let httpClient = TestHttpClient(postHandler: { _ in
            return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
        })
        httpConnectionOptions.httpClientFactory = { options in httpClient }

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidOpenHandler = { connection in
            XCTAssert(false)
        }

        connectionDelegate.connectionDidFailToOpenHandler = { error in
            XCTAssertNil(httpConnection.connectionId)
            connectionIdNotSetExpectation.fulfill()
        }

        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatNegotiatePreservesQueryParameters() {
        let negotiateExpectation = expectation(description: "negotiate")
        let connectionDidFailToOpenExpectation = expectation(description: "failedToOpen")

        let httpConnectionOptions = HttpConnectionOptions()
        let httpClient = TestHttpClient(postHandler: { url in
            XCTAssertEqual("http://fakeuri.org/negotiate?testParam=42&negotiateVersion=1", url.absoluteString)
            negotiateExpectation.fulfill()
            return (HttpResponse(statusCode: 500, contents: nil), nil)
        })

        httpConnectionOptions.httpClientFactory = { options in httpClient }
        let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org?testParam=42")!, options: httpConnectionOptions)

        let connectionDelegate = TestConnectionDelegate()
        connectionDelegate.connectionDidFailToOpenHandler = { _ in
            connectionDidFailToOpenExpectation.fulfill()
        }
        httpConnection.delegate = connectionDelegate

        httpConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testConnectionForwardsInherentKeepAliveFromTransport() {
        for inherentKeepAlive in [true, false] {
            let connectionOpenedExpectation = expectation(description: "connection opened")
            let httpConnectionOptions = HttpConnectionOptions()
            let transport = TestTransport()
            transport.inherentKeepAlive = inherentKeepAlive
            let httpConnection = HttpConnection(url: URL(string:"http://fakeuri.org/")!, options: httpConnectionOptions, transportFactory: TestTransportFactory(transport), logger: PrintLogger())
            let httpClient = TestHttpClient(postHandler: { _ in
                return (HttpResponse(statusCode: 200, contents: self.negotiatePayload.data(using: .utf8)!), nil)
            })
            httpConnectionOptions.httpClientFactory = { options in httpClient }

            let connectionDelegate = TestConnectionDelegate()
            connectionDelegate.connectionDidOpenHandler = { connection in
                connectionOpenedExpectation.fulfill()
                connection.stop(stopError: nil)
            }

            httpConnection.delegate = connectionDelegate
            httpConnection.start()
            XCTAssertEqual(inherentKeepAlive, httpConnection.inherentKeepAlive)

            waitForExpectations(timeout: 5 /*seconds*/)
        }
    }
}
