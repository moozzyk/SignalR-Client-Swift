//
//  AppDelegate.swift
//  SignalRSample
//
//  Created by Pawel Kadluczka on 2/23/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import Cocoa
import SignalRClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var testButton: NSButton!

    let wsTransport: WebsocketsTransport = WebsocketsTransport()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func btnSend(sender: AnyObject) {
        wsTransport.start(url: URL(string: "ws://echo.websocket.org")!)
    }
}

