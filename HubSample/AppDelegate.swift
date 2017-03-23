//
//  AppDelegate.swift
//  HubSample
//
//  Created by Pawel Kadluczka on 3/22/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Cocoa
import SignalRClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var sendBtn: NSButton!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var chatTableView: NSTableView!

    var chatHubConnection: HubConnection?
    var chatHubConnectionDelegate: ChatHubConnectionDelegate?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        sendBtn.isEnabled = false
        msgTextField.isEnabled = false

        chatHubConnectionDelegate = ChatHubConnectionDelegate(app: self)

        // TODO: query should not be needed
        chatHubConnection = HubConnection(url: URL(string:"http://localhost:5000/chat")!, query: "")
        chatHubConnection!.delegate = chatHubConnectionDelegate
        chatHubConnection!.on(method: "NewMessage", callback: {args in
            /*
            self.chatTableView.beginUpdates()
            self.chatTableView.insertText("test")
            self.chatTableView.endUpdates()
            */
            
        })
        chatHubConnection!.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        chatHubConnection?.stop()
    }

    func connectionDidStart() {
        sendBtn.isEnabled = true
        msgTextField.isEnabled = true
    }

    @IBAction func btnSend(sender: AnyObject) {
        let message = msgTextField.stringValue
        if msgTextField.stringValue != "" {
            chatHubConnection?.invoke(method: "Broadcast", arguments: ["Swift", message], invocationDidComplete: {error in
                // TODO: print error
            })
        }
    }
}

class ChatHubConnectionDelegate: HubConnectionDelegate {
    weak var app: AppDelegate?

    init(app: AppDelegate) {
        self.app = app
    }

    func connectionDidOpen(hubConnection: HubConnection!) {
        app?.connectionDidStart()
    }

    func connectionDidFailToOpen(error: Error) {
    }

    func connectionDidClose(error: Error?) {
    }
}

