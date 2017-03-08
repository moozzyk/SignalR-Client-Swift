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
    private var pendingCalls = [Int: (InvocationResult)->Void]()
    private let jsonSerializer: JSONInvocationSerializer = JSONInvocationSerializer()

    private var connection: SocketConnection!
    public weak var delegate: HubConnectionDelegate!

    public convenience init(url: URL, query: String) {
        self.init(connection: Connection(url: url, query: query))
    }

    public init(connection: SocketConnection!) {
        self.connection = connection
        self.hubConnectionQueue = DispatchQueue(label: "SignalR.hubconnection.queue")
        socketConnectionDelegate = HubSocketConnectionDelegate(hubConnection: self)
        self.connection.delegate = socketConnectionDelegate
    }

    public func start() {
        connection.start()
    }

    public func stop() {
        connection.stop()
    }

    public func invoke<T>(method: String, arguments: [Any?], returnType: T.Type, invocationDidComplete: @escaping (_ result: T?, _ error: Error?)->Void) {
        var id:Int = 0

        let callback: (InvocationResult)->Void = { invocationResult in

                if let hubInvocationError = invocationResult.error {
                    invocationDidComplete(nil, SignalRError.hubInvocationError(message: hubInvocationError))
                    return
                }

                do {
                    try invocationDidComplete(invocationResult.getResult(type: T.self), nil);
                }
                catch {
                    invocationDidComplete(nil, error)
                }
        };

        hubConnectionQueue.sync {
            invocationId = invocationId + 1
            id = invocationId
            pendingCalls[id] = callback
        }

        let invocationDescriptor = InvocationDescriptor(id: id, method: method, arguments: arguments)
        let invocationData = jsonSerializer.writeInvocationDescriptor(invocationDescriptor: invocationDescriptor)
        do {
            try connection.send(data: invocationData)
        }
        catch {
            hubConnectionQueue.sync {
                _ = pendingCalls.removeValue(forKey: id)
            }

            invocationDidComplete(nil, error)
        }
    }

    fileprivate func hubConnectionDidReceiveData(data: Data) {
        do {
            let incomingMessage = try jsonSerializer.processIncomingData(data: data)
            if let invocationResult = incomingMessage as? InvocationResult {
                var callback: ((InvocationResult)->Void)?
                self.hubConnectionQueue.sync {
                    callback = self.pendingCalls.removeValue(forKey: invocationResult.id)
                }

                if callback == nil {
                    print("Could not find callback with id \(invocationResult.id)")
                    return
                }

                callback!(invocationResult)
            }
        }
        catch {
            print(error)
        }
    }
}

public class HubSocketConnectionDelegate : SocketConnectionDelegate {
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
        hubConnection?.delegate.connectionDidClose(error: error)
    }
}

