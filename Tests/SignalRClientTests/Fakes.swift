//
//  Fakes.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 11/23/19.
//
import Foundation
import SignalRClient

class TestConnectionDelegate: ConnectionDelegate {
    var connectionDidOpenHandler: ((_ connection: Connection) -> Void)?
    var connectionDidFailToOpenHandler: ((_ error: Error) -> Void)?
    var connectionDidCloseHandler: ((_ error: Error?) -> Void)?
    var connectionDidReceiveDataHandler: ((_ connection: Connection, _ data: Data) -> Void)?
    var connectionWillReconnectHandler: ((_ error: Error?)->Void)?
    var connectionDidReconnectHandler: (()->Void)?

    func connectionDidOpen(connection: Connection) {
        connectionDidOpenHandler?(connection)
    }

    func connectionDidFailToOpen(error: Error) {
        connectionDidFailToOpenHandler?(error)
    }

    func connectionDidReceiveData(connection: Connection, data: Data) {
        connectionDidReceiveDataHandler?(connection, data)
    }

    func connectionDidClose(error: Error?) {
        connectionDidCloseHandler?(error)
    }

    func connectionWillReconnect(error: Error) {
        connectionWillReconnectHandler?(error)
    }

    func connectionDidReconnect() {
        connectionDidReconnectHandler?()
    }
}

class TestHttpClient: HttpClientProtocol {
    
    typealias RequestHandler = (URL) -> (HttpResponse?, Error?)
    
    private var getHandler: RequestHandler?
    private var postHandler: RequestHandler?
    private var deleteHandler: RequestHandler?

    init(getHandler: RequestHandler? = nil, postHandler: RequestHandler? = nil, deleteHandler: RequestHandler? = nil) {
        self.getHandler = getHandler
        self.postHandler = postHandler
        self.deleteHandler = deleteHandler
    }

    func get(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        handleHttpRequest(url: url, body: nil, handler: getHandler, completionHandler: completionHandler)
    }

    func post(url: URL, body: Data?, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        handleHttpRequest(url: url, body: body, handler: postHandler, completionHandler: completionHandler)
    }
    
    func delete(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        handleHttpRequest(url: url, body: nil, handler: deleteHandler, completionHandler: completionHandler)
    }

    private func handleHttpRequest(url: URL, body: Data?, handler: RequestHandler?, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        let (response, error) = (handler?(url)) ?? (nil, nil)
        completionHandler(response, error)
    }
}
