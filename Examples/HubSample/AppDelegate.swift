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

    private var chatHubConnection: HubConnection?
    private var chatHubConnectionDelegate: HubConnectionDelegate?
    private var name = ""
    private var messages: [String] = []
    private var reconnectAlert: NSAlert?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        chatTableView.delegate = self
        chatTableView.dataSource = self

        sendBtn.isEnabled = false
        msgTextField.isEnabled = false

        name = getName()

        chatHubConnectionDelegate = ChatHubConnectionDelegate(app: self)
        chatHubConnection = HubConnectionBuilder(url: URL(string:"http://localhost:5000/chat")!) // /chat or /chatLongPolling or /chatWebSockets
            .withHubConnectionDelegate(delegate: chatHubConnectionDelegate!)
            .withAutoReconnect()
            .withLogging(minLogLevel: .debug)
            .withHubConnectionOptions(configureHubConnectionOptions: {options in options.keepAliveInterval = 20 })
            .build()

        chatHubConnection!.on(method: "NewMessage", callback: { (user: String, message: String) in
            self.appendMessage(message: "\(user): \(message)")
        })
        chatHubConnection!.start()
    }

    func getName() -> String {
        let alert = NSAlert()
        alert.messageText = "Enter your Name"
        alert.addButton(withTitle: "OK")

        let textField = NSTextField(string: "")
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
        blockUI(message: "Connection failed to start.", error: error)
    }

    func connectionDidClose(error: Error?) {
        if let alert = reconnectAlert {
            alert.window.orderOut(nil)
        }
        blockUI(message: "Connection is closed.", error: error)
    }

    fileprivate func connectionWillReconnect(error: Error?) {
        guard reconnectAlert == nil else {
            print("Alert already present. This is unexpected.")
            return
        }

        reconnectAlert = NSAlert()
        reconnectAlert!.messageText = "Reconnecting..."
        reconnectAlert!.informativeText = "Please wait."
        reconnectAlert!.addButton(withTitle: "Hidden button")
        reconnectAlert!.buttons[0].isHidden = true
        reconnectAlert?.beginSheetModal(for: self.window, completionHandler: nil)
    }

    fileprivate func connectionDidReconnect() {
        reconnectAlert?.window.orderOut(nil)
        reconnectAlert = nil
    }

    func blockUI(message: String, error: Error?) {
        var message = message
        if let e = error {
            message.append(" Error: \(e)")
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
        if message != "" {
            chatHubConnection?.invoke(method: "Broadcast", name, message) { error in
                if let e = error {
                    self.appendMessage(message: "Error: \(e)")
                }
            }
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
            if let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MessageID"), owner: self) as? NSTableCellView {
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

    func connectionDidOpen(hubConnection: HubConnection) {
        app?.connectionDidStart()
    }

    func connectionDidFailToOpen(error: Error) {
        app?.connectionDidFailToOpen(error: error)
    }

    func connectionDidClose(error: Error?) {
        app?.connectionDidClose(error: error)
    }

    func connectionWillReconnect(error: Error) {
        app?.connectionWillReconnect(error: error)
    }

    func connectionDidReconnect() {
        app?.connectionDidReconnect()
    }
}
