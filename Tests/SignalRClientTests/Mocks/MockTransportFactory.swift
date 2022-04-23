import Foundation
@testable import SignalRClient

typealias TestTransportFactory = MockTransportFactory

class MockTransportFactory: TransportFactory {
    public var currentTransport: Transport?

    func createTransport(availableTransports: [TransportDescription]) throws -> Transport {
        if availableTransports.contains(where: {$0.transportType == .webSockets}) {
            currentTransport = WebsocketsTransport(logger: PrintLogger())
        } else if availableTransports.contains(where: {$0.transportType == .longPolling}) {
            currentTransport = LongPollingTransport(logger: PrintLogger())
        }
        return currentTransport!
    }
}
