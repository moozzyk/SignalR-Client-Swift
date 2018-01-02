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
    private var pendingCalls = [String: (CompletionMessage?, Error?)->Void]()
    private var callbacks = [String: ([Any?], TypeConverter) -> Void]()

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
        connection.send(data: "{ \"protocol\": \"\(hubProtocol.name)\" }\u{1e}".data(using: .utf8)!) { error in
            if let e = error {
                delegate.connectionDidFailToOpen(error: e)
            }
            else {
                delegate.connectionDidOpen(hubConnection: self)
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

    public func invoke(method: String, arguments: [Any?], invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        invoke(method: method, arguments: arguments, returnType: Any.self, invocationDidComplete: {_, error in
            invocationDidComplete(error)
        })
    }

    public func invoke<T>(method: String, arguments: [Any?], returnType: T.Type, invocationDidComplete: @escaping (_ result: T?, _ error: Error?) -> Void) {

        // TODO: Should it be just result and converter instead of Completion message?
        let callback: (CompletionMessage?, Error?) -> Void = { completionMessage, error in

            if error != nil {
                invocationDidComplete(nil, error!)
                return
            }

            if let hubInvocationError = completionMessage!.error {
                invocationDidComplete(nil, SignalRError.hubInvocationError(message: hubInvocationError))
                return
            }

            if !completionMessage!.hasResult {
                invocationDidComplete(nil, nil)
                return
            }

            do {
                let result = try self.hubProtocol.typeConverter.convertFromWireType(obj: completionMessage!.result, targetType: T.self)
                invocationDidComplete(result, nil)
            } catch {
                invocationDidComplete(nil, error)
            }
        }

        var id:String = ""
        hubConnectionQueue.sync {
            invocationId = invocationId + 1
            id = "\(invocationId)"
            pendingCalls[id] = callback
        }

        let invocationMessage = InvocationMessage(invocationId: id, target: method, arguments: arguments, nonBlocking: false)
        do {
            let invocationData = try hubProtocol.writeMessage(message: invocationMessage)
            connection.send(data: invocationData) { error in
                if let e = error {
                    failInvocationWithError(invocationDidComplete: invocationDidComplete, invocationId: id, error: e)
                }
            }
        } catch {
            failInvocationWithError(invocationDidComplete: invocationDidComplete, invocationId: id, error: error)
        }
    }

    fileprivate func failInvocationWithError<T>(invocationDidComplete: @escaping (_ result: T?, _ error: Error?)->Void, invocationId: String, error: Error) {
        hubConnectionQueue.sync {
            _ = pendingCalls.removeValue(forKey: invocationId)
        }

        invocationDidComplete(nil, error)
    }

    fileprivate func hubConnectionDidReceiveData(data: Data) {
        do {
            let messages = try hubProtocol.parseMessages(input: data)
            for incomingMessage in messages {
                switch(incomingMessage.messageType) {
                case MessageType.Completion:
                    try handleInvocationCompletion(message: incomingMessage as! CompletionMessage)
                case MessageType.StreamItem:
                    try handleStreamItem(message: incomingMessage as! StreamItemMessage)
                case MessageType.Invocation:
                    try handleInvocation(message: incomingMessage as! InvocationMessage)
                default:
                    print("Unexpected message")
                }
            }
        } catch {
            print(error)
        }
    }

    fileprivate func handleInvocationCompletion(message: CompletionMessage) throws {
        var callback: ((CompletionMessage?, Error?)->Void)?
        self.hubConnectionQueue.sync {
            callback = self.pendingCalls.removeValue(forKey: message.invocationId)
        }

        if callback != nil {
            Util.dispatchToMainThread {
                callback!(message, nil)
            }
        }
        else {
            print("Could not find callback with id \(message.invocationId)")
        }
    }

    fileprivate func handleStreamItem(message: StreamItemMessage) throws {
        throw SignalRError.invalidOperation(message: "Not supported")
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
        hubConnectionQueue.sync {
            for callback in pendingCalls.values {
                Util.dispatchToMainThread {
                    callback(nil, invocationError)
                }
            }
            pendingCalls.removeAll()
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

