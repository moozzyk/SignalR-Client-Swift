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
}

class TestHttpClient: HttpClientProtocol {
    private var getHandler: ((URL) -> (HttpResponse?, Error?))?
    private var postHandler: ((URL) -> (HttpResponse?, Error?))?

    init(getHandler: ((URL) -> (HttpResponse?, Error?))?, postHandler: ((URL) -> (HttpResponse?, Error?))?) {
        self.getHandler = getHandler
        self.postHandler = postHandler
    }

    convenience init(getHandler: ((URL) -> (HttpResponse?, Error?))?) {
        self.init(getHandler: getHandler, postHandler: nil)
    }

    convenience init(postHandler: ((URL) -> (HttpResponse?, Error?))?) {
        self.init(getHandler: nil, postHandler: postHandler)
    }

    convenience init() {
        self.init(getHandler: nil, postHandler: nil)
    }

    func get(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        handleHttpRequest(url: url, handler: getHandler, completionHandler: completionHandler)
    }

    func post(url: URL, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        handleHttpRequest(url: url, handler: postHandler, completionHandler: completionHandler)
    }

    private func handleHttpRequest(url: URL, handler: ((URL) -> (HttpResponse?, Error?))?, completionHandler: @escaping (HttpResponse?, Error?) -> Void) {
        let (response, error) = (handler?(url)) ?? (nil, nil)
        completionHandler(response, error)
    }
}
