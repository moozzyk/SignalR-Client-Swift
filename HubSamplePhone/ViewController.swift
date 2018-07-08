//
//  ViewController.swift
//  HubSamplePhone
//
//  Created by Pawel Kadluczka on 2/11/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import UIKit
import SignalRClient

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Update the Url accordingly
    private let serverUrl = "http://192.168.0.105:5000/chat"
    private let dispatchQueue = DispatchQueue(label: "hubsamplephone.queue.dispatcheueuq")

    var chatHubConnection: HubConnection?
    var chatHubConnectionDelegate: ChatHubConnectionDelegate?
    var name = ""
    var messages: [String] = []

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var msgTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        let alert = UIAlertController(title: "Enter your Name", message:"", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField() { textField in textField.placeholder = "Name"}
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            self.name = alert.textFields?.first?.text ?? "John Doe"

            self.chatHubConnectionDelegate = ChatHubConnectionDelegate(controller: self)
            self.chatHubConnection = HubConnectionBuilder(url: URL(string: self.serverUrl)!).build()
            self.chatHubConnection!.delegate = self.chatHubConnectionDelegate
            self.chatHubConnection!.on(method: "NewMessage", callback: {args, typeConverter in
                let user = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)
                let message = try! typeConverter.convertFromWireType(obj: args[1], targetType: String.self)
                self.appendMessage(message: "\(user!): \(message!)")
            })
            self.chatHubConnection!.start()

        }
        alert.addAction(OKAction)
        self.present(alert, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        chatHubConnection?.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnSend(_ sender: Any) {
        let message = msgTextField.text
        if message != "" {
            chatHubConnection?.invoke(method: "Broadcast", arguments: [name, message], invocationDidComplete:
                {error in
                    if let e = error {
                        self.appendMessage(message: "Error: \(e)")
                    }
            })
            msgTextField.text = ""
        }
    }

    private func appendMessage(message: String) {
        self.dispatchQueue.sync {
            self.messages.append(message)
        }

        self.chatTableView.beginUpdates()
        self.chatTableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
        self.chatTableView.endUpdates()
        self.chatTableView.scrollToRow(at: IndexPath(item: messages.count-1, section: 0), at: .bottom, animated: true)
    }

    fileprivate func connectionDidOpen() {
        toggleUI(isEnabled: true)
    }

    fileprivate func connectionDidFailToOpen(error: Error) {
        appendMessage(message: "Connection failed to start. Error \(error)")
        toggleUI(isEnabled: false)
    }

    fileprivate func connectionDidClose(error: Error?) {
        var message = "Connection closed."
        if let e = error {
            message.append(" Error: \(e)")
        }
        appendMessage(message: message)
        toggleUI(isEnabled: false)
    }

    func toggleUI(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
        msgTextField.isEnabled = isEnabled
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = -1
        dispatchQueue.sync {
            count = self.messages.count
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = messages[row]
        return cell
    }
}

class ChatHubConnectionDelegate: HubConnectionDelegate {
    weak var controller: ViewController?

    init(controller: ViewController) {
        self.controller = controller
    }

    func connectionDidOpen(hubConnection: HubConnection!) {
        controller?.connectionDidOpen()
    }

    func connectionDidFailToOpen(error: Error) {
        controller?.connectionDidFailToOpen(error: error)
    }

    func connectionDidClose(error: Error?) {
        controller?.connectionDidClose(error: error)
    }
}
