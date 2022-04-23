import XCTest
@testable import SignalRClient

class ArgumentExtractorTests: XCTestCase {
    func testThatArgumentExtractorCallsIntoClientInvocationMessage() {
        let payload = "{ \"type\": 1, \"target\": \"method\", \"arguments\": [42, \"abc\"] }\u{001e}"

        let hubMessages = try! JSONHubProtocol(logger: NullLogger()).parseMessages(input: payload.data(using: .utf8)!)
        XCTAssertEqual(1, hubMessages.count)
        let msg = hubMessages[0] as! ClientInvocationMessage
        let argumentExtractor = ArgumentExtractor(clientInvocationMessage: msg)
        XCTAssertTrue(argumentExtractor.hasMoreArgs())
        XCTAssertEqual(42, try! argumentExtractor.getArgument(type: Int.self))
        XCTAssertTrue(argumentExtractor.hasMoreArgs())
        XCTAssertEqual("abc", try! argumentExtractor.getArgument(type: String.self))
        XCTAssertFalse(argumentExtractor.hasMoreArgs())
    }
}
