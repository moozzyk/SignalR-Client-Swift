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
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var sendBtn: NSButton!
    @IBOutlet weak var msgTextField: NSTextField!
    @IBOutlet weak var chatTableView: NSTableView!

    private let dispatchQueue = DispatchQueue(label: "hubsample.queue.dispatcheueuq")

    var chatHubConnection: HubConnection?
    var chatHubConnectionDelegate: ChatHubConnectionDelegate?
    var name = ""
    var messages: [String] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        chatTableView.delegate = self
        chatTableView.dataSource = self

        sendBtn.isEnabled = false
        msgTextField.isEnabled = false

        name = getName()

        chatHubConnectionDelegate = ChatHubConnectionDelegate(app: self)

        // TODO: query should not be needed
        chatHubConnection = HubConnection(url: URL(string:"http://localhost:5000/chat")!, query: "")
        chatHubConnection!.delegate = chatHubConnectionDelegate
        chatHubConnection!.on(method: "NewMessage", callback: {args in
            self.appendMessage(message: "\(args[0]!): \(args[1]!)")

        })
        chatHubConnection!.start()
    }

    func getName() -> String {
        let alert = NSAlert()
        alert.messageText = "Enter your Name"
        alert.addButton(withTitle: "OK")

        let textField = NSTextField(string: nil)
        textField.placeholderString = "Name"
        textField.setFrameSize(NSSize(width: 250, height: textField.frame.height))

        alert.accessoryView = textField

        alert.runModal()

        return textField.stringValue
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        chatHubConnection?.stop()
    }

    func connectionDidStart() {
        toggleUI(isEnabled: true)
    }

    func connectionDidFailToOpen(error: Error)
    {
        appendMessage(message: "Connection failed to start. Error \(error)")
        toggleUI(isEnabled: false)
    }

    func connectionDidClose(error: Error?) {
        var message = "Connection closed."
        if error != nil {
            message.append(" Error: \(error)")
        }
        appendMessage(message: message)
        toggleUI(isEnabled: false)
    }

    func toggleUI(isEnabled: Bool) {
        sendBtn.isEnabled = isEnabled
        msgTextField.isEnabled = isEnabled
    }

    func appendMessage(message: String) {
        self.dispatchQueue.sync {
            self.messages.append(message)
        }

        self.chatTableView.beginUpdates()
        let index = IndexSet(integer: self.chatTableView.numberOfRows)
        self.chatTableView.insertRows(at: index)
        self.chatTableView.endUpdates()
        self.chatTableView.scrollRowToVisible(self.chatTableView.numberOfRows - 1)
    }

    @IBAction func btnSend(sender: AnyObject) {
        let message = msgTextField.stringValue
        if msgTextField.stringValue != "" {
            chatHubConnection?.invoke(method: "Broadcast", arguments: [name, message], invocationDidComplete:
                {error in
                    if error != nil {
                        self.appendMessage(message: "Error: \(error)")
                    }
                })
            msgTextField.stringValue = ""
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        var count = -1
        dispatchQueue.sync {
            count = self.messages.count
        }
        return count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView != chatTableView {
            return nil
        }

        if tableColumn == chatTableView.tableColumns[0] {

            if let cellView = tableView.make(withIdentifier: "MessageID", owner: self) as? NSTableCellView {
                cellView.textField?.stringValue = messages[row]
                return cellView
            }
        }

        return nil
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
        app?.connectionDidFailToOpen(error: error)
    }

    func connectionDidClose(error: Error?) {
        app?.connectionDidClose(error: error)
    }
}

