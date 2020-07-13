//
//  LongPollingTransport.swift
//  SignalRClient
//
//  Created by David Robertson on 13/07/2020.
//

import Foundation

public class LongPollingTransport: Transport {
    
    public var delegate: TransportDelegate?
    
    private let logger: Logger
    private let pollQueue: DispatchQueue = DispatchQueue(label: "LongPollingTransport")
    
    private var active = false
    private var opened = false
    private var closeCalled = false
    private var httpClient: HttpClientProtocol?
    private var url: URL?
    
    private var closeError: Error?
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    public func start(url: URL, options: HttpConnectionOptions) {
        logger.log(logLevel: .info, message: "Starting LongPolling transport")
        httpClient = options.httpClientFactory(options)
        self.url = url
        opened = false
        closeError = nil
        closeCalled = false
        active = true
        triggerPoll()
    }
    
    public func send(data: Data, sendDidComplete: @escaping (Error?) -> Void) {
        guard active, let httpClient = httpClient, let url = url else {
            sendDidComplete(SignalRError.invalidState)
            return
        }
        httpClient.post(url: url, body: data) { (responseOptional, errorOptional) in
            if let error = errorOptional {
                sendDidComplete(error)
            } else if let response = responseOptional {
                if response.statusCode == 200 {
                    sendDidComplete(nil)
                } else {
                    sendDidComplete(SignalRError.webError(statusCode: response.statusCode))
                }
            }
        }
    }
    
    public func close() {
        if !closeCalled {
            closeCalled = true
            active = false
            pollQueue.async {
                self.logger.log(logLevel: .debug, message: "Sending LongPolling session DELETE request...")
                self.httpClient?.delete(url: self.url!, completionHandler: { (_, errorOptional) in
                    if let error = errorOptional {
                        self.logger.log(logLevel: .error, message: "Error while DELETE-ing long polling session: \(error)")
                        self.delegate?.transportDidClose(error)
                    } else {
                        self.logger.log(logLevel: .info, message: "LongPolling transport stopped.")
                        self.delegate?.transportDidClose(self.closeError)
                    }
                })
            }
        }
    }
    
    
    // MARK: - Private methods
    
    private func triggerPoll() {
        self.pollQueue.async {
            if self.active {
                self.poll()
            } else {
                self.logger.log(logLevel: .debug, message: "Long Polling transport polling complete.")
                self.close()
            }
        }
    }
    
    private func poll() {
        let pollUrl = getPollUrl()
        logger.log(logLevel: .debug, message: "Polling \(pollUrl)")
        
        httpClient?.get(url: pollUrl, completionHandler: { (responseOptional, errorOptional) in
            if let error = errorOptional {
                if (error as? URLError)?.errorCode == NSURLErrorTimedOut {
                    self.logger.log(logLevel: .debug, message: "Poll timed out (client side), reissuing.")
                } else {
                    self.logger.log(logLevel: .error, message: "Error during polling: \(error)")
                    self.closeError = error
                    self.active = false
                }
                
            } else if let response = responseOptional {
                switch response.statusCode {
                case 204:
                    self.logger.log(logLevel: .info, message: "LongPolling transport terminated by server.")
                    self.closeError = nil
                    self.active = false
                    
                case 200:
                    if !self.opened {
                        // First response must be discarded.
                        self.opened = true
                        self.delegate?.transportDidOpen()
                    } else if let data = response.contents, data.count > 0 {
                        self.logger.log(logLevel: .debug, message: "Message received: \(data)")
                        self.delegate?.transportDidReceiveData(data)
                    } else {
                        self.logger.log(logLevel: .debug, message: "Poll timed out (server side), reissuing.")
                    }
                    
                default:
                    self.logger.log(logLevel: .error, message: "Unexpected response code \(response.statusCode)")
                    self.closeError = SignalRError.webError(statusCode: response.statusCode)
                    self.active = false
                }
            }
            
            self.triggerPoll()
        })
        
    }
    
    private func getPollUrl() -> URL {
        var components = URLComponents.init(url: self.url!, resolvingAgainstBaseURL: true)!
        if components.queryItems == nil {
            components.queryItems = []
        }
        let millisecondUnixTime = Int(Date().timeIntervalSince1970 * 1000)
        components.queryItems?.append(URLQueryItem(name: "_", value: String(millisecondUnixTime)))
        let pollUrl = components.url
        return pollUrl!
    }
    
}
