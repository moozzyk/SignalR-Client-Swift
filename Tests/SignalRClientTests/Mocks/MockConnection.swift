import Foundation
@testable import SignalRClient

typealias TestConnection = MockConnection

class MockConnection: Connection {
    var connectionId: String?

    var delegate: ConnectionDelegate?
    var sendDelegate: ((_ data: Data, _ sendDidComplete: (_ error: Error?) -> Void) -> Void)?

    var inherentKeepAlive = false

    func start() {
        connectionId = "00000000-0000-0000-C000-000000000046"
        delegate?.connectionDidOpen(connection: self)
        delegate?.connectionDidReceiveData(connection: self, data: "{}\u{1e}".data(using: .utf8)!)
    }

    func send(data: Data, sendDidComplete: (_ error: Error?) -> Void) {
        sendDelegate?(data, sendDidComplete)
    }

    func stop(stopError: Error? = nil) -> Void {
        connectionId = nil
        delegate?.connectionDidClose(error: stopError)
    }
}
