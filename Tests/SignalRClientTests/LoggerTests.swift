//
//  LoggerTests.swift
//  SignalRClientTests
//
//  Created by Pawel Kadluczka on 8/2/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class LoggerTests: XCTestCase {

    func testThatFilteringLoggerLogsPerMinLogLevel() {
        class TestLogger: Logger {
            var logLevels: [LogLevel] = []
            func log(logLevel: LogLevel, message: @autoclosure () -> String) {
                logLevels.append(logLevel)
            }
        }

        let minLogLevel = LogLevel.warning
        let testLogger = TestLogger()
        let logger = FilteringLogger(minLogLevel: minLogLevel, logger: testLogger)

        let logEntries: [LogLevel] = [.warning, .error, .warning, .info, .debug, .error]
        logEntries.forEach {logger.log(logLevel: $0, message: "")}

        XCTAssertEqual(logEntries.filter {$0.rawValue <= minLogLevel.rawValue}, testLogger.logLevels)
    }
}
