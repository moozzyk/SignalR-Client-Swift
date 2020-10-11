//
//  Constants.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 10/1/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

let BASE_URL = "http://localhost:5000"

let ECHO_URL = URL(string: "\(BASE_URL)/echo")!
let ECHO_WEBSOCKETS_URL = URL(string: "\(BASE_URL)/echoWebSockets")!
let ECHO_LONGPOLLING_URL = URL(string: "\(BASE_URL)/echoLongPolling")!
let ECHO_NOTRANSPORTS_URL = URL(string: "\(BASE_URL)/echoNoTransports")!

let TESTHUB_URL = URL(string: "\(BASE_URL)/testhub")!
let TESTHUB_WEBSOCKETS_URL = URL(string: "\(BASE_URL)/testhubWebSockets")!
let TESTHUB_LONGPOLLING_URL = URL(string: "\(BASE_URL)/testhubLongPolling")!

// Used by most tests that don't depend on a specific transport directly
let TARGET_ECHO_URL = ECHO_URL // ECHO_URL or ECHO_WEBSOCKETS_URL or ECHO_LONGPOLLING_URL
let TARGET_TESTHUB_URL = TESTHUB_URL // TESTHUB_URL or TESTHUB_WEBSOCKETS_URL or TESTHUB_LONGPOLLING_URL
