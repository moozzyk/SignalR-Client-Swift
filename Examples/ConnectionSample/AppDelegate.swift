//
//  AppDelegate.swift
//  ConnectionSample
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Cocoa
import SignalRClient
import Combine

@available(macOS 10.15, *)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var openBtn: NSButton!
    @IBOutlet weak var sendBtn: NSButton!
    @IBOutlet weak var closeBtn: NSButton!

    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var logTextField: NSTextField!
    @IBOutlet weak var historyTextField: NSTextField!

    var echoConnection: Connection?
    var echoConnectionDelegate: ConnectionDelegate?



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        toggleSend(isEnabled: false)
        appendLog(string: "Log")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        echoConnection?.stop(stopError: nil)
    }

    var reactiveConnection: CombineHTTPConnection?
    var subscriptions = Set<AnyCancellable>()

    @IBAction func btnOpen(sender: AnyObject) {
        let url = URL(string: urlTextField.stringValue)!
//        echoConnection = HttpConnection(url: url)
//        echoConnectionDelegate = EchoConnectionDelegate(app: self)
//        echoConnection!.delegate = echoConnectionDelegate
//        echoConnection!.start()

        let options: HttpConnectionOptions = .init()
        options.headers = [
            "access-token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc0ltcGVyc29uYXRlQnlJbnRyYW5ldCI6ZmFsc2UsImN1c3RvbWVySWQiOiI1Yzk1NjM5NmVjYTllMDAwMTAwZWYzYTAiLCJhY2Nlc3NUb2tlbklkIjoiNjBkMGM1MDQ0OTBkMTkwMDE5ZTYxMGYwIiwiYWNjZXNzVG9rZW5IYXNoIjoiMWY0ZTFiMjA5NWJlYjVkMjRlMmRmNDM2NmFhMDMxMmU3ZTBiNWQzMDliMTdlYWE5YzM0ZmFmYTNiYjE1NjM5NCIsImlhdCI6MTYyNDI5NDY2MCwiZXhwIjoxNjI0ODk5NDYwfQ.uFrjrADAEA22yxMERTO_vIYq9lTpzT_TZ9gHx5rcy0M"
        ]
        reactiveConnection = CombineHTTPConnection(
            url: url,//.init(string: "https://api-core-trade-marketdata.dev.warren.com.br/tickerhub")!,
            options: options,
            logger: NullLogger()
        )
        reactiveConnection?.publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    print("finished")
                }
            },
            receiveValue: { event in
                switch event {
                case .opened(_):
                    self.toggleSend(isEnabled: true)
                case let .gotData(_, data):
                    print(String(data: data, encoding: .utf8))
                case let .succesfullySentData(data):
                    print(String(data: data, encoding: .utf8))
                case let .failedToSendData(data, error):
                    print(String(data: data, encoding: .utf8))
                    print(error)
                case let .willReconnectAfterFailure(error):
                    print(error)
                case .reconnected:
                    print("reconnected")
                case .closed:
                    print("closed")
                }
            }
        )
        .store(in: &subscriptions)

        reactiveConnection?.start()
    }

    @IBAction func btnSend(sender: AnyObject) {
        appendLog(string: "Sending: " + msgTextField.stringValue)
        echoConnection?.send(data: msgTextField.stringValue.data(using: .utf8)!) { error in
            if let e = error {
                print(e)
            }
        }

        reactiveConnection?.send(data: msgTextField.stringValue.data(using: .utf8)!)

        msgTextField.stringValue = ""
    }

    @IBAction func btnClose(sender: AnyObject) {
        echoConnection?.stop(stopError: nil)

        reactiveConnection?.stop()
    }

    func toggleSend(isEnabled: Bool) {
        urlTextField.isEnabled = !isEnabled
        openBtn.isEnabled = !isEnabled

        msgTextField.isEnabled = isEnabled
        sendBtn.isEnabled = isEnabled
        closeBtn.isEnabled = isEnabled
    }

    func appendLog(string: String) {
        logTextField.stringValue += string + "\n"
    }
}

@available(macOS 10.15, *)
class EchoConnectionDelegate: ConnectionDelegate {

    weak var app: AppDelegate?

    init(app: AppDelegate) {
        self.app = app
    }

    func connectionDidOpen(connection: Connection) {
        app?.appendLog(string: "Connection started")
        app?.toggleSend(isEnabled: true)
    }

    func connectionDidFailToOpen(error: Error) {
        app?.appendLog(string: "Error")
    }

    func connectionDidReceiveData(connection: Connection, data: Data) {
        app?.appendLog(string: "Received: " + String(data: data, encoding: .utf8)!)
    }

    func connectionDidClose(error: Error?) {
        app?.appendLog(string: "Connection stopped")
        if error != nil {
            print(error.debugDescription)
            app?.appendLog(string: error.debugDescription)
        }

        app?.toggleSend(isEnabled: false)
    }
}
