import Foundation
@testable import SignalRClient

typealias TestConnectionDelegate = MockConnectionDelegate

class MockConnectionDelegate: ConnectionDelegate {
    var connectionDidOpenHandler: ((_ connection: Connection) -> Void)?
    var connectionDidFailToOpenHandler: ((_ error: Error) -> Void)?
    var connectionDidCloseHandler: ((_ error: Error?) -> Void)?
    var connectionDidReceiveDataHandler: ((_ connection: Connection, _ data: Data) -> Void)?
    var connectionWillReconnectHandler: ((_ error: Error?)->Void)?
    var connectionDidReconnectHandler: (()->Void)?

    func connectionDidOpen(connection: Connection) {
        connectionDidOpenHandler?(connection)
    }

    func connectionDidFailToOpen(error: Error) {
        connectionDidFailToOpenHandler?(error)
    }

    func connectionDidReceiveData(connection: Connection, data: Data) {
        connectionDidReceiveDataHandler?(connection, data)
    }

    func connectionDidClose(error: Error?) {
        connectionDidCloseHandler?(error)
    }

    func connectionWillReconnect(error: Error) {
        connectionWillReconnectHandler?(error)
    }

    func connectionDidReconnect() {
        connectionDidReconnectHandler?()
    }
}

