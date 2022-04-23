import Foundation
@testable import SignalRClient

typealias TestHubConnectionDelegate = MockHubConnectionDelegate

class MockHubConnectionDelegate: HubConnectionDelegate {
    var connectionDidOpenHandler: ((_ hubConnection: HubConnection) -> Void)?
    var connectionDidFailToOpenHandler: ((_ error: Error) -> Void)?
    var connectionDidCloseHandler: ((_ error: Error?) -> Void)?
    var connectionWillReconnectHandler: ((_ error: Error) -> Void)?
    var connectionDidReconnectHandler: (() -> Void)?

    func connectionDidOpen(hubConnection: HubConnection) {
        connectionDidOpenHandler?(hubConnection)
    }

    func connectionDidFailToOpen(error: Error) {
        connectionDidFailToOpenHandler?(error)
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
