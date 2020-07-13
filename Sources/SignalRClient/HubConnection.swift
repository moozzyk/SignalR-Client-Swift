//
//  HubConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

/**
`HubConnection` is the client for interacting with SignalR server. It allows invoking server side hub methods and register handlers for client side methods that can be invoked from the server.

 - note: You need to maintain the reference to the `HubConnection` instance until the connection is stopped
 */
public class HubConnection {

    private var invocationId: Int = 0
    private let hubConnectionQueue: DispatchQueue
    private var pendingCalls = [String: ServerInvocationHandler]()
    private var callbacks = [String: (ArgumentExtractor) throws -> Void]()
    private var handshakeStatus: HandshakeStatus = .needsHandling(false)
    private let logger: Logger

    private var connection: Connection
    private var connectionDelegate: HubConnectionConnectionDelegate?
    private var hubProtocol: HubProtocol

    /**
    Allows setting a delegate that will be notified about connection lifecycle events

     - note: You need to maintain the reference of the `HubConnectionDelegate` instance for the entire lifetime of the connection
     */
    public weak var delegate: HubConnectionDelegate?
    
    /**
     Gets the connections connectionId. This value will be cleared when the connection is stopped and will have a new value every time the connection is successfully started.
     */
    public var connectionId: String? {
        return connection.connectionId
    }

    /**
     Initializes a `HubConnection` with an underlying connection, a hub protocol and an optional logger.

     - parameter connection: underlying `Connection`
     - parameter hubProtocol: `HubProtocol` to use to communicate with the server
     - parameter logger: optional logger to write logs. If not provided no log will be written
     */
    public init(connection: Connection, hubProtocol: HubProtocol, logger: Logger = NullLogger()) {
        logger.log(logLevel: .debug, message: "HubConnection init")
        self.connection = connection
        self.hubProtocol = hubProtocol
        self.logger = logger
        self.hubConnectionQueue = DispatchQueue(label: "SignalR.hubconnection.queue")
    }

    deinit {
        logger.log(logLevel: .debug, message: "HubConnection deinit")
    }

    /**
     Starts the connection.

     - note: Use `HubConnectionDelegate` to receive connection lifecycle notifications.
    */
    public func start() {
        self.connectionDelegate = HubConnectionConnectionDelegate(hubConnection: self)
        self.connection.delegate = connectionDelegate
        logger.log(logLevel: .info, message: "Starting hub connection")
        connection.start()
    }

    fileprivate func initiateHandshake() {
        logger.log(logLevel: .info, message: "Hub connection started")
        // TODO: support custom protcols
        // TODO: add negative test (e.g. invalid protocol)
        let handshakeRequest = HandshakeProtocol.createHandshakeRequest(hubProtocol: hubProtocol)
        logger.log(logLevel: .debug, message: "Sending handshake request: \(handshakeRequest)")
        connection.send(data: "\(handshakeRequest)".data(using: .utf8)!) { error in
            if let e = error {
                self.logger.log(logLevel: .error, message: "Sending handshake request failed: \(e)")
                // TODO: (BUG) if this fails when reconnecting the callback should not be called and there
                // will be no further reconnect attempts
                self.delegate?.connectionDidFailToOpen(error: e)
            }
        }
    }

    /**
     Stops the connection.
    */
    public func stop() {
        logger.log(logLevel: .info, message: "Stopping hub connection")
        connection.stop(stopError: nil)
    }

    /**
     Allows registering callbacks for client side hub methods.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter argumentExtractor: an object allowing extracting arguments for the callback
     - note: Consider using typed `.on` extension methods defined on the `HubConnectionExtensions` class.
     */
    public func on(method: String, callback: @escaping (_ argumentExtractor: ArgumentExtractor) throws -> Void) {
        logger.log(logLevel: .info, message: "Registering client side hub method: '\(method)'")

        var callbackRegistered = false
        hubConnectionQueue.sync {
            callbackRegistered = callbacks.keys.contains(method)
            callbacks[method] = callback
        }

        if (callbackRegistered) {
            logger.log(logLevel: .warning, message: "Client side hub method '\(method)' was already registered and was overwritten")
        }
    }

    /**
     Invokes a server side hub method in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arguments: hub method arguments
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     - note: Consider using typed `.send()` extension methods defined on the `HubConnectionExtensions` class.
     */
    public func send(method: String, arguments:[Encodable], sendDidComplete: @escaping (_ error: Error?) -> Void) {
        logger.log(logLevel: .info, message: "Sending to server side hub method: '\(method)'")

        if !ensureConnectionStarted(errorHandler: {sendDidComplete($0)}) {
            return
        }

        do {
            let invocationMessage = ServerInvocationMessage(target: method, arguments: arguments)
            let invocationData = try hubProtocol.writeMessage(message: invocationMessage)
            connection.send(data: invocationData, sendDidComplete: sendDidComplete)
        } catch {
            logger.log(logLevel: .error, message: "Sending to server side hub method '\(method)' failed. Error: \(error)")
            sendDidComplete(error)
        }
    }

    /**
     Invokes a server side hub method that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arguments: hub method arguments
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - note: Consider using typed `.invoke()` extension methods defined on the `HubConnectionExtensions` class.
     */
    public func invoke(method: String, arguments: [Encodable], invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        invoke(method: method, arguments: arguments, resultType: DecodableVoid.self, invocationDidComplete: {_, error in
            invocationDidComplete(error)
        })
    }

    /**
     Invokes a server side hub method that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arguments: hub method arguments
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - note: Consider using typed `.invoke()` extension methods defined on the `HubConnectionExtensions` class
     */
    public func invoke<T: Decodable>(method: String, arguments: [Encodable], resultType: T.Type, invocationDidComplete: @escaping (_ result: T?, _ error: Error?) -> Void) {
        logger.log(logLevel: .info, message: "Invoking server side hub method: '\(method)'")

        if !ensureConnectionStarted(errorHandler: {invocationDidComplete(nil, $0)}) {
            return
        }

        let invocationHandler = InvocationHandler<T>(logger: logger, invocationDidComplete: invocationDidComplete)

        _ = invoke(invocationHandler: invocationHandler, method: method, arguments: arguments)
    }

    /**
     Invokes a streaming server side hub method.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arguments: hub method arguments
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: Consider using typed `.stream()` extension methods defined on the `HubConnectionExtensions` class.
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", arguments: [10, 1], streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    public func stream<T: Decodable>(method: String, arguments: [Encodable], streamItemReceived: @escaping (_ item: T) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        logger.log(logLevel: .info, message: "Invoking server side streaming hub method: '\(method)'")

        if !ensureConnectionStarted(errorHandler: {invocationDidComplete($0)}) {
            return StreamHandle(invocationId: "")
        }

        let streamInvocationHandler = StreamInvocationHandler<T>(logger: logger, streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)

        let id = invoke(invocationHandler: streamInvocationHandler, method: method, arguments: arguments)

        return StreamHandle(invocationId: id)
    }

    /**
     Cancels a streaming hub method.

     - parameter streamHandle: a `StreamHandle` identifying a hub method returned from the `stream` method
     - parameter cancelDidFail: an error handler that will be invoked if cancelling a stream method failed
     - parameter error: contains failure details if cancelling a stream method failed
     */
    public func cancelStreamInvocation(streamHandle: StreamHandle, cancelDidFail: @escaping (_ error: Error) -> Void) {
        logger.log(logLevel: .info, message: "Cancelling server side streaming hub method")

        if !ensureConnectionStarted(errorHandler: {cancelDidFail($0)}) {
            return
        }

        if streamHandle.invocationId == "" {
            logger.log(logLevel: .error, message: "Invalid stream handle")
            cancelDidFail(SignalRError.invalidOperation(message: "Invalid stream handle."))
            return
        }

        let cancelInvocationMessage = CancelInvocationMessage(invocationId: streamHandle.invocationId)
        do {
            let cancelInvocationData = try hubProtocol.writeMessage(message: cancelInvocationMessage)
            connection.send(data: cancelInvocationData, sendDidComplete: {error in
                if let e = error {
                    self.logger.log(logLevel: .error, message: "Sending cancellation of server side streaming hub returned error: \(e)")
                    cancelDidFail(e)
                }
            })
        } catch {
            logger.log(logLevel: .error, message: "Sending cancellation of server side streaming hub method failed: \(error)")
            cancelDidFail(error)
        }
    }

    fileprivate func invoke(invocationHandler: ServerInvocationHandler, method: String, arguments: [Encodable]) -> String {
        logger.log(logLevel: .info, message: "Invoking server side hub method '\(method)' with \(arguments.count) argument(s)")
        var id:String = ""
        hubConnectionQueue.sync {
            invocationId = invocationId + 1
            id = "\(invocationId)"
            pendingCalls[id] = invocationHandler
        }

        do {
            let invocationMessage = invocationHandler.createInvocationMessage(invocationId: id, method: method, arguments: arguments)
            let invocationData = try hubProtocol.writeMessage(message: invocationMessage)

            connection.send(data: invocationData) { error in
                if let e = error {
                    self.logger.log(logLevel: .error, message: "Invoking server hub method \(method) returned error: \(e)")
                    self.failInvocationWithError(invocationHandler: invocationHandler, invocationId: id, error: e)
                }
            }
        } catch {
            logger.log(logLevel: .error, message: "Invoking server hub method \(method) failed: \(error)")
            failInvocationWithError(invocationHandler: invocationHandler, invocationId: id, error: error)
        }

        return id
    }

    private func failInvocationWithError(invocationHandler: ServerInvocationHandler, invocationId: String, error: Error) {
        hubConnectionQueue.sync {
            _ = pendingCalls.removeValue(forKey: invocationId)
        }

        Util.dispatchToMainThread {
            invocationHandler.raiseError(error: error)
        }
    }

    private func ensureConnectionStarted(errorHandler: (Error)->Void) -> Bool {
        if !handshakeStatus.isHandled {
            logger.log(logLevel: .error, message: "Attempting to send data before connection has been started.")
            errorHandler(SignalRError.invalidOperation(message: "Attempting to send data before connection has been started."))
            return false
        }
        return true
    }

    fileprivate func connectionDidReceiveData(data: Data) {
        logger.log(logLevel: .debug, message: "Data received")
        var data = data
        if !handshakeStatus.isHandled {
            logger.log(logLevel: .debug, message: "Processing handshake response: \(String(data: data, encoding: .utf8) ?? "(invalid)")")
            let (error, remainingData) = HandshakeProtocol.parseHandshakeResponse(data: data)
            data = remainingData
            let originalHandshakeStatus = handshakeStatus
            handshakeStatus = .handled
            if let e = error {
                // TODO: (BUG) if this fails when reconnecting the callback should not be called and there
                // will be no further reconnect attempts
                logger.log(logLevel: .error, message: "Parsing handshake response failed: \(e)")
                delegate?.connectionDidFailToOpen(error: e)
                return
            }
            if originalHandshakeStatus.isReconnect {
                delegate?.connectionDidReconnect()
            } else {
                delegate?.connectionDidOpen(hubConnection: self)
            }
        }
        do {
            let messages = try hubProtocol.parseMessages(input: data)
            for incomingMessage in messages {
                switch(incomingMessage.type) {
                case MessageType.Completion:
                    try handleCompletion(message: incomingMessage as! CompletionMessage)
                case MessageType.StreamItem:
                    try handleStreamItem(message: incomingMessage as! StreamItemMessage)
                case MessageType.Invocation:
                    handleInvocation(message: incomingMessage as! ClientInvocationMessage)
                case MessageType.Close:
                    connection.stop(stopError: SignalRError.serverClose(message: (incomingMessage as! CloseMessage).error))
                case MessageType.Ping:
                    // no action required for ping messages
                    break
                default:
                    logger.log(logLevel: .error, message: "Usupported message type: \(incomingMessage.type.rawValue)")
                }
            }
        } catch {
            logger.log(logLevel: .debug, message: "Parsing message failed: \(error)")
        }
    }

    private func handleCompletion(message: CompletionMessage) throws {
        var serverInvocationHandler: ServerInvocationHandler?
        self.hubConnectionQueue.sync {
            serverInvocationHandler = self.pendingCalls.removeValue(forKey: message.invocationId)
        }

        if serverInvocationHandler != nil {
            Util.dispatchToMainThread {
                serverInvocationHandler!.processCompletion(completionMessage: message)
            }
        } else {
            logger.log(logLevel: .error, message: "Could not find callback with id \(message.invocationId)")
        }
    }

    private func handleStreamItem(message: StreamItemMessage) throws {
        var serverInvocationHandler: ServerInvocationHandler?
        self.hubConnectionQueue.sync {
            serverInvocationHandler = self.pendingCalls[message.invocationId]
        }

        if serverInvocationHandler != nil {
            Util.dispatchToMainThread {
                if let error = serverInvocationHandler!.processStreamItem(streamItemMessage: message) {
                    self.logger.log(logLevel: .error, message: "Processing stream item failed: \(error)")
                    self.failInvocationWithError(invocationHandler: serverInvocationHandler!, invocationId: message.invocationId, error: error)
                }
            }
        } else {
            logger.log(logLevel: .error, message: "Could not find callback with id \(message.invocationId)")
        }
    }

    private func handleInvocation(message: ClientInvocationMessage) {
        var callback: ((ArgumentExtractor) throws -> Void)?

        self.hubConnectionQueue.sync {
            callback = self.callbacks[message.target]
        }

        if callback != nil {
            Util.dispatchToMainThread {
                do {
                    try callback!(ArgumentExtractor(clientInvocationMessage: message))
                } catch {
                    self.logger.log(logLevel: .error, message: "Invoking client hub method \(message.target) failed due to: \(error)")
                }
            }
        } else {
            logger.log(logLevel: .error, message: "No handler registered for method \'\(message.target)\'")
        }
    }

    fileprivate func connectionDidClose(error: Error?) {
        logger.log(logLevel: .info, message: "HubConnection closing with error: \(String(describing: error))")

        var invocationHandlers: [ServerInvocationHandler] = []
        hubConnectionQueue.sync {
            invocationHandlers = [ServerInvocationHandler](pendingCalls.values)
            pendingCalls.removeAll()
        }

        logger.log(logLevel: .info, message: "Terminating \(invocationHandlers.count) pending hub methods")
        let invocationError = error ?? SignalRError.hubInvocationCancelled
        for serverInvocationHandler in invocationHandlers {
            Util.dispatchToMainThread {
                serverInvocationHandler.raiseError(error: invocationError)
            }
        }
        handshakeStatus = .needsHandling(false)
        delegate?.connectionDidClose(error: error)
    }

    fileprivate func connectionDidFailToOpen(error: Error) {
        delegate?.connectionDidFailToOpen(error: error)
    }

    fileprivate func connectionWillReconnect(error: Error) {
        handshakeStatus = .needsHandling(true)
        delegate?.connectionWillReconnect(error: error)
    }

    fileprivate func connectionDidReconnect() {
        initiateHandshake()
    }
}

fileprivate class HubConnectionConnectionDelegate: ConnectionDelegate {
    private weak var hubConnection: HubConnection?
    init(hubConnection: HubConnection) {
        self.hubConnection = hubConnection
    }

    func connectionDidOpen(connection: Connection) {
        hubConnection?.initiateHandshake()
    }

    func connectionDidFailToOpen(error: Error) {
        hubConnection?.connectionDidFailToOpen(error: error)
    }

    func connectionDidReceiveData(connection: Connection, data: Data) {
        hubConnection?.connectionDidReceiveData(data: data)
    }

    func connectionDidClose(error: Error?) {
        hubConnection?.connectionDidClose(error: error)
    }

    func connectionWillReconnect(error: Error) {
        hubConnection?.connectionWillReconnect(error: error)
    }

    func connectionDidReconnect() {
        hubConnection?.connectionDidReconnect()
    }
}

/**
 A helper class used for retrieving arguments of invocations of client side method.
 */
public class ArgumentExtractor {
    let clientInvocationMessage: ClientInvocationMessage

    /**
     Initializes an `ArgumentExtractor` with the received `ClientInvocationMessage`.

     - parameter clientInvocationMessage: a `ClientInvocationMessage` containing client side method invocation details
     */
    init(clientInvocationMessage: ClientInvocationMessage) {
        self.clientInvocationMessage = clientInvocationMessage
    }

    /**
     Retrieves next argument of the client side method to invoke and advances to the next argument.

     - parameter type: the type of the argument that is being retrieved
     - returns: a value of the argument
     - throws: an error if:
        - the requested `type` is not compatible with the actual value
        - there are no more arguments to be retrieved
     */
    public func getArgument<T: Decodable>(type: T.Type) throws -> T {
        return try clientInvocationMessage.getArgument(type: type)
    }

    /**
     Allows to check if there are more arguments to retrieve.

     - returns: `true` if there are more arguments to retrieve. `false` otherwise
     */
    public func hasMoreArgs() -> Bool {
        return clientInvocationMessage.hasMoreArgs
    }
}

fileprivate enum HandshakeStatus {
    case needsHandling(/*isReconnect*/ Bool)
    case handled
}

extension HandshakeStatus {
    var isHandled: Bool {
        if case .handled = self {
            return true
        }
        return false
    }

    var isReconnect: Bool {
        switch self {
        case .needsHandling(let isReconnect):
            return isReconnect
        default:
            return false
        }
    }
}
