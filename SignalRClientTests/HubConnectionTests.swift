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

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
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

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!)
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

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!)
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatExceptionsInHubMethodsAreTurnedIntoErrors() {
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

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!)
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatPendingInvocationsAreCancelledWhenConnectionIsClosed() {
        let invocationCancelledExpectation = expectation(description: "invocation cancelled")

        let testSocketConnection = TestSocketConnection()
        let hubConnection = HubConnection(connection: testSocketConnection, hubProtocol: JSONHubProtocol())
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()
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

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testThatPendingInvocationsAreAbortedWhenConnectionIsClosedWithError() {
        let invocationCancelledExpectation = expectation(description: "invocation cancelled")
        let testError = NSError()

        let testSocketConnection = TestSocketConnection()
        let hubConnection = HubConnection(connection: testSocketConnection, hubProtocol: JSONHubProtocol())
        let hubConnectionDelegate = TestHubConnectionDelegate()
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()
        hubConnection.invoke(method: "TestMethod", arguments: [], invocationDidComplete: { error in
            XCTAssertEqual(testError, error as! NSError)
            invocationCancelledExpectation.fulfill()
        })
        testSocketConnection.delegate?.connectionDidClose(error: testError)

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

        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!)
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "GetNumber", callback: { args, _ in
            XCTAssertNotNil(args)
            XCTAssertEqual(1, args.count)
            XCTAssertEqual(42, args[0] as! Int)
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

        let hubProtocol = JSONHubProtocol(typeConverter: PersonTypeConverter())
        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!, hubProtocol: hubProtocol)
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.on(method: "GetPerson", callback: { arguments, typeConverter in
            XCTAssertNotNil(arguments)
            let person = try! typeConverter.convertFromWireType(obj: arguments[0], targetType: User.self)
            XCTAssertEqual("Jerzy", person!.firstName)
            XCTAssertEqual("Meteor", person!.lastName)
            XCTAssertEqual(34, person!.age)
            XCTAssertEqual(179.0, person!.height)
            XCTAssertEqual(Sex.Male, person!.sex)
            didInvokeClientMethod.fulfill()
            hubConnection.stop()
        })

        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
    }

    enum Sex {
        case Male
        case Female
    }

    class User {
        public let firstName: String
        let lastName: String
        let age: Int?
        let height: Double?
        let sex: Sex?

        init(firstName: String, lastName: String, age: Int?, height: Double?, sex: Sex?) {
            self.firstName = firstName
            self.lastName = lastName
            self.age = age
            self.height = height
            self.sex = sex
        }
    }

    class PersonTypeConverter: JSONTypeConverter {
        override func convertToWireType(obj: Any?) throws -> Any? {
            if let user = obj as? User? {
                return convertUser(user: user)
            }

            if let users = obj as? [User?] {
                return users.map({u in convertUser(user:u)})
            }

            return try super.convertToWireType(obj: obj)
        }

        private func convertUser(user: User?) -> [String: Any?]? {

            if let u = user {
                return [
                    "firstName": u.firstName,
                    "lastName": u.lastName,
                    "age": u.age,
                    "height": u.height,
                    "sex": u.sex == Sex.Male ? 0 : 1]
            }

            return nil
        }

        override func convertFromWireType<T>(obj: Any?, targetType: T.Type) throws -> T? {

            if let userDictionary = obj as? [String: Any?]? {
                return materializeUser(userDictionary: userDictionary) as? T
            }

            if let userArray = obj as? [[String: Any?]?] {

                let result: [User?] = userArray.map({userDictionary in
                    return materializeUser(userDictionary: userDictionary)
                })

                return result as? T
            }

            return try super.convertFromWireType(obj: obj, targetType: targetType)
        }

        private func materializeUser(userDictionary: [String: Any?]?) -> User? {
            if let user = userDictionary {
                return User(firstName: user["firstName"] as! String, lastName: user["lastName"] as! String, age: user["age"] as! Int?, height: user["height"] as! Double?, sex: user["sex"] as! Int == 0 ? Sex.Male : Sex.Female)

            }

            return nil
        }
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

            hubConnection.invoke(method: "SortByName", arguments: [input], returnType: [User].self, invocationDidComplete: { people, error in
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


        let hubProtocol = JSONHubProtocol(typeConverter: PersonTypeConverter())
        let hubConnection = HubConnection(url: URL(string: "http://localhost:5000/testhub")!, hubProtocol: hubProtocol)
        hubConnection.delegate = hubConnectionDelegate
        hubConnection.start()

        waitForExpectations(timeout: 5 /*seconds*/)
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

class TestSocketConnection: SocketConnection {
    var delegate: SocketConnectionDelegate!
    func start(transport: Transport? = nil) -> Void {
        delegate?.connectionDidOpen(connection: self)
    }

    func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
    }

    func stop() -> Void {
        delegate?.connectionDidClose(error: nil)
    }
}
