//
//  HubConnection.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/4/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Foundation

public class HubConnection {

    private var invocationId: Int = 0
    private let hubConnectionQueue: DispatchQueue
    private var socketConnectionDelegate: HubSocketConnectionDelegate?
    private var pendingCalls = [String: ServerInvocationHandler]()
    private var callbacks = [String: ([Any?], TypeConverter) -> Void]()
    private var handshakeHandled = false

    private var connection: SocketConnection!
    private var hubProtocol: HubProtocol!
    public weak var delegate: HubConnectionDelegate!

    public convenience init(url: URL) {
        self.init(connection: Connection(url: url), hubProtocol: JSONHubProtocol())
    }

    public convenience init(url: URL, hubProtocol: HubProtocol) {
        self.init(connection: Connection(url: url), hubProtocol: hubProtocol)
    }

    public init(connection: SocketConnection!, hubProtocol: HubProtocol) {
        self.connection = connection
        self.hubProtocol = hubProtocol
        self.hubConnectionQueue = DispatchQueue(label: "SignalR.hubconnection.queue")
        socketConnectionDelegate = HubSocketConnectionDelegate(hubConnection: self)
        self.connection.delegate = socketConnectionDelegate
    }

    public func start(transport: Transport? = nil) {
        connection.start(transport: transport)
    }

    fileprivate func connectionStarted() {
        // TODO: support custom protcols
        // TODO: add negative test (e.g. invalid protocol)
        connection.send(data: "\(HandshakeProtocol.createHandshakeRequest(hubProtocol: hubProtocol))".data(using: .utf8)!) { error in
            if let e = error {
                delegate.connectionDidFailToOpen(error: e)
            }
        }
    }

    public func stop() {
        connection.stop()
    }

    public func on(method: String, callback: @escaping (_ arguments: [Any?], _ typeConverter: TypeConverter) -> Void) {
        hubConnectionQueue.sync {
            // TODO: warn for conflicts?
            callbacks[method] = callback
        }
    }

    public func send(method: String, arguments:[Any?], sendDidComplete: @escaping (_ error: Error?) -> Void) {
        let invocationMessage = InvocationMessage(target: method, arguments: arguments)
        do {
            let invocationData = try hubProtocol.writeMessage(message: invocationMessage)
            connection.send(data: invocationData, sendDidComplete: sendDidComplete)
        } catch {
            sendDidComplete(error)
        }
    }

    public func invoke(method: String, arguments: [Any?], invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        invoke(method: method, arguments: arguments, returnType: Any.self, invocationDidComplete: {_, error in
            invocationDidComplete(error)
        })
    }

    public func invoke<T>(method: String, arguments: [Any?], returnType: T.Type, invocationDidComplete: @escaping (_ result: T?, _ error: Error?) -> Void) {

        let invocationHandler = InvocationHandler<T>(typeConverter: self.hubProtocol.typeConverter, invocationDidComplete: invocationDidComplete)

        _ = invoke(invocationHandler: invocationHandler, method: method, arguments: arguments)
    }

    public func stream<T>(method: String, arguments: [Any?], itemType: T.Type, streamItemReceived: @escaping (_ item: T?) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        let streamInvocationHandler = StreamInvocationHandler<T>(typeConverter: self.hubProtocol.typeConverter, streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)

        let id = invoke(invocationHandler: streamInvocationHandler, method: method, arguments: arguments)

        return StreamHandle(invocationId: id)
    }

    public func cancelStreamInvocation(streamHandle: StreamHandle, cancelDidFail: @escaping (_ error: Error) -> Void) {
        hubConnectionQueue.sync {
            _ = pendingCalls.removeValue(forKey: streamHandle.invocationId)
        }

        let cancelInvocationMessage = CancelInvocationMessage(invocationId: streamHandle.invocationId)
        do {
            let cancelInvocationData = try hubProtocol.writeMessage(message: cancelInvocationMessage)
            connection.send(data: cancelInvocationData, sendDidComplete: {error in
                if error != nil {
                    cancelDidFail(error!)
                }
            })
        } catch {
            cancelDidFail(error)
        }
    }

    fileprivate func invoke(invocationHandler: ServerInvocationHandler, method: String, arguments: [Any?]) -> String {
        var id:String = ""
        hubConnectionQueue.sync {
            invocationId = invocationId + 1
            id = "\(invocationId)"
            pendingCalls[id] = invocationHandler
        }

        let invocationMessage = invocationHandler.createInvocationMessage(invocationId: id, method: method, arguments: arguments)
        do {
            let invocationData = try hubProtocol.writeMessage(message: invocationMessage)
            connection.send(data: invocationData) { error in
                if let e = error {
                    failInvocationWithError(invocationHandler: invocationHandler, invocationId: id, error: e)
                }
            }
        } catch {
            failInvocationWithError(invocationHandler: invocationHandler, invocationId: id, error: error)
        }

        return id
    }

    fileprivate func failInvocationWithError(invocationHandler: ServerInvocationHandler, invocationId: String, error: Error) {
        hubConnectionQueue.sync {
            _ = pendingCalls.removeValue(forKey: invocationId)
        }

        Util.dispatchToMainThread {
            invocationHandler.raiseError(error: error)
        }
    }

    fileprivate func hubConnectionDidReceiveData(data: Data) {
        var data = data
        if !handshakeHandled {
            let (error, remainingData) = HandshakeProtocol.parseHandshakeResponse(data: data)
            handshakeHandled = true
            data = remainingData
            if let e = error {
                delegate.connectionDidFailToOpen(error: e)
                return
            }
            delegate.connectionDidOpen(hubConnection: self)
        }
        do {
            let messages = try hubProtocol.parseMessages(input: data)
            for incomingMessage in messages {
                switch(incomingMessage.messageType) {
                case MessageType.Completion:
                    try handleCompletion(message: incomingMessage as! CompletionMessage)
                case MessageType.StreamItem:
                    try handleStreamItem(message: incomingMessage as! StreamItemMessage)
                case MessageType.Invocation:
                    try handleInvocation(message: incomingMessage as! InvocationMessage)
                case MessageType.Ping:
                    // no action required for ping messages
                    break;
                default:
                    print("Unexpected message")
                }
            }
        } catch {
            print(error)
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
            print("Could not find callback with id \(message.invocationId)")
        }
    }

    fileprivate func handleStreamItem(message: StreamItemMessage) throws {
        var serverInvocationHandler: ServerInvocationHandler?
        self.hubConnectionQueue.sync {
            serverInvocationHandler = self.pendingCalls[message.invocationId]
        }

        if serverInvocationHandler != nil {
            Util.dispatchToMainThread {
                if let error = serverInvocationHandler!.processStreamItem(streamItemMessage: message) {
                    self.failInvocationWithError(invocationHandler: serverInvocationHandler!, invocationId: message.invocationId, error: error)
                }
            }
        } else {
            print("Could not find callback with id \(message.invocationId)")
        }
    }

    fileprivate func handleInvocation(message: InvocationMessage) throws {
        var callback: (([Any?], TypeConverter) -> Void)?

        self.hubConnectionQueue.sync {
            callback = self.callbacks[message.target]
        }

        if callback != nil {
            Util.dispatchToMainThread {
                callback!(message.arguments, self.hubProtocol.typeConverter)
            }
        } else {
            print("No handler registered for method \'\(message.target)\'")
        }
    }

    fileprivate func hubConnectionDidClose(error: Error?) {
        let invocationError = error ?? SignalRError.hubInvocationCancelled
        var invocationHandlers: [ServerInvocationHandler] = []
        hubConnectionQueue.sync {
            invocationHandlers = [ServerInvocationHandler](pendingCalls.values)
            pendingCalls.removeAll()
        }

        for serverInvocationHandler in invocationHandlers {
            Util.dispatchToMainThread {
                serverInvocationHandler.raiseError(error: invocationError)
            }
        }

        delegate.connectionDidClose(error: error)
    }
}

fileprivate class HubSocketConnectionDelegate : SocketConnectionDelegate {
    private weak var hubConnection: HubConnection?

    fileprivate init(hubConnection: HubConnection!) {
        self.hubConnection = hubConnection
    }

    public func connectionDidOpen(connection: SocketConnection!) {
        hubConnection?.connectionStarted()
    }

    public func connectionDidFailToOpen(error: Error) {
        hubConnection?.delegate.connectionDidFailToOpen(error: error)
    }

    public func connectionDidReceiveData(connection: SocketConnection!, data: Data) {
        hubConnection?.hubConnectionDidReceiveData(data: data)
    }

    public func connectionDidClose(error: Error?) {
        hubConnection?.hubConnectionDidClose(error: error)
    }
}
