//
//  AppDelegate.swift
//  SocketsSample
//
//  Created by Pawel Kadluczka on 2/26/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Cocoa
import SignalRClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var openBtn: NSButton!
    @IBOutlet weak var sendBtn: NSButton!
    @IBOutlet weak var closeBtn: NSButton!

    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var logTextField: NSTextField!

    var echoConnection: Connection?
    var echoConnectionDelegate: ConnectionDelegate?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        toggleSend(isEnabled: false)
        appendLog(string: "Log")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        echoConnection?.stop()
    }

    @IBAction func btnOpen(sender: AnyObject) {
        let url = URL(string: urlTextField.stringValue)!
        echoConnection = Connection(url: url)
        echoConnectionDelegate = EchoConnectionDelegate(app: self)
        echoConnection!.delegate = echoConnectionDelegate
        echoConnection!.start()
    }

    @IBAction func btnSend(sender: AnyObject) {
        do {
            appendLog(string: "Sending: " + msgTextField.stringValue)
            try echoConnection?.send(data: msgTextField.stringValue.data(using: .utf8)!)
            msgTextField.stringValue = ""
        }
        catch {
            // TODO: Add to log
            print(error)
        }
    }

    @IBAction func btnClose(sender: AnyObject) {
        echoConnection?.stop()
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

class EchoConnectionDelegate: ConnectionDelegate {

    weak var app: AppDelegate?

    init(app: AppDelegate) {
        self.app = app
    }

    func connectionDidOpen(connection: Connection!) {
        app?.appendLog(string: "Connection started")
        app?.toggleSend(isEnabled: true)
    }

    func connectionDidReceiveData(connection: Connection!, data: Data) {
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
