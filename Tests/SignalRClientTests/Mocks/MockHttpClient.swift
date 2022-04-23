import Foundation
@testable import SignalRClient

typealias TestHttpClient = MockHttpClient

class MockHttpClient: HttpClientProtocol {
    
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
