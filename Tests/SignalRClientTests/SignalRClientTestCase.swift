import XCTest
@testable import SignalRClient

class SignalRClientTestCase: XCTestCase {
    
    let BASE_URL = "http://localhost:5000"
    
    lazy var ECHO_URL = URL(string: "\(BASE_URL)/echo")!
    lazy var ECHO_WEBSOCKETS_URL = URL(string: "\(BASE_URL)/echoWebSockets")!
    lazy var ECHO_LONGPOLLING_URL = URL(string: "\(BASE_URL)/echoLongPolling")!
    lazy var ECHO_NOTRANSPORTS_URL = URL(string: "\(BASE_URL)/echoNoTransports")!
    
    lazy var TESTHUB_URL = URL(string: "\(BASE_URL)/testhub")!
    lazy var TESTHUB_WEBSOCKETS_URL = URL(string: "\(BASE_URL)/testhubWebSockets")!
    lazy var TESTHUB_LONGPOLLING_URL = URL(string: "\(BASE_URL)/testhubLongPolling")!
    
    // Used by most tests that don't depend on a specific transport directly
    
    // ECHO_URL or ECHO_WEBSOCKETS_URL or ECHO_LONGPOLLING_URL
    lazy var TARGET_ECHO_URL = ECHO_URL
    // TESTHUB_URL or TESTHUB_WEBSOCKETS_URL or TESTHUB_LONGPOLLING_URL
    lazy var TARGET_TESTHUB_URL = TESTHUB_URL
    
    /// When `true` tests that require a running server will be skipped
    ///
    /// ```sh
    /// swift test -Xswiftc -DWITHOUT_LIVE_SERVER
    /// ```
    var runningWithoutLiveServer: Bool {
        #if WITHOUT_LIVE_SERVER
        return true
        #else
        return false
        #endif
    }
}
