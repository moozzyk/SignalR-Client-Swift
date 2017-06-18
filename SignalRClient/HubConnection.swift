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
    private var pendingCalls = [Int: (InvocationResult?, Error?)->Void]()
    private var callbacks = [String: ([Any?]) -> Void]()

    private var connection: SocketConnection!
    private var invocationSerializer: InvocationSerializer!
    public weak var delegate: HubConnectionDelegate!

    public convenience init(url: URL, invocationSerializer: InvocationSerializer? = nil) {
        self.init(connection: Connection(url: url), invocationSerializer: invocationSerializer)
    }

    public init(connection: SocketConnection!, invocationSerializer: InvocationSerializer? = nil) {
        self.connection = connection
        self.invocationSerializer = invocationSerializer ?? JSONInvocationSerializer()
        self.hubConnectionQueue = DispatchQueue(label: "SignalR.hubconnection.queue")
        socketConnectionDelegate = HubSocketConnectionDelegate(hubConnection: self)
        self.connection.delegate = socketConnectionDelegate
    }

    public func start(transport: Transport? = nil) {
        connection.start(transport: transport)
    }

    public func stop() {
        connection.stop()
    }

    public func on(method: String, callback: @escaping (_ arguments: [Any?]) -> Void) {
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

    public func invoke<T>(method: String, arguments: [Any?], returnType: T.Type, invocationDidComplete: @escaping (_ result: T?, _ error: Error?)->Void) {
        var id:Int = 0

        let callback: (InvocationResult?, Error?)->Void = { invocationResult, error in

            if error != nil {
                invocationDidComplete(nil, error!)
                return
            }

            if let hubInvocationError = invocationResult!.error {
                invocationDidComplete(nil, SignalRError.hubInvocationError(message: hubInvocationError))
                return
            }

            do {
                try invocationDidComplete(invocationResult!.getResult(type: T.self), nil);
            } catch {
                invocationDidComplete(nil, error)
            }
        };

        hubConnectionQueue.sync {
            invocationId = invocationId + 1
            id = invocationId
            pendingCalls[id] = callback
        }

        let invocationDescriptor = InvocationDescriptor(id: id, method: method, arguments: arguments)

        do {
            let invocationData = try invocationSerializer.writeInvocationDescriptor(invocationDescriptor: invocationDescriptor)
            connection.send(data: invocationData) { error in
                if let e = error {
                    failInvocationWithError(invocationDidComplete: invocationDidComplete, invocationId: invocationId, error: e)
                }
            }
        } catch {
            failInvocationWithError(invocationDidComplete: invocationDidComplete, invocationId: invocationId, error: error)
        }
    }

    fileprivate func failInvocationWithError<T>(invocationDidComplete: @escaping (_ result: T?, _ error: Error?)->Void, invocationId: Int, error: Error) {
        hubConnectionQueue.sync {
            _ = pendingCalls.removeValue(forKey: invocationId)
        }

        invocationDidComplete(nil, error)
    }

    fileprivate func hubConnectionDidReceiveData(data: Data) {
        do {
            let incomingMessage = try invocationSerializer.processIncomingData(data: data)
            switch incomingMessage {
            case let invocationResult as InvocationResult:
                var callback: ((InvocationResult?, Error?)->Void)?
                self.hubConnectionQueue.sync {
                    callback = self.pendingCalls.removeValue(forKey: invocationResult.id)
                }

                if callback != nil {
                    Util.dispatchToMainThread {
                        callback!(invocationResult, nil)
                    }
                }
                else {
                    print("Could not find callback with id \(invocationResult.id)")
                }
            case let invocationDescriptor as InvocationDescriptor:
                var callback: (([Any?])->Void)?

                self.hubConnectionQueue.sync {
                    callback = self.callbacks[invocationDescriptor.method]
                }

                if callback != nil {
                    Util.dispatchToMainThread {
                        callback!(invocationDescriptor.arguments)
                    }
                }
                else {
                    print("No handler registered for method \(invocationDescriptor.method)")
                }
            default:
                print("Unexpected type")
            }
        } catch {
            print(error)
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
        hubConnection?.delegate.connectionDidOpen(hubConnection: hubConnection!)
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

