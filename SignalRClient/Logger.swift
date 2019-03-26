//
//  Logger.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 8/2/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case error = 1
    case warning = 2
    case info = 3
    case debug = 4
}

public protocol Logger {
    func log(logLevel: LogLevel, message: @autoclosure () -> String)
}

public extension LogLevel {
    func toString() -> String {
        switch (self) {
        case LogLevel.error: return "error"
        case LogLevel.warning: return "warning"
        case LogLevel.info: return "info"
        case LogLevel.debug: return "debug"
        }
    }
}

public class PrintLogger: Logger {
    let dateFormatter: DateFormatter

    public init() {
        dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    }

    public func log(logLevel: LogLevel, message: @autoclosure () -> String) {
        print("\(dateFormatter.string(from: Date())) \(logLevel.toString()): \(message())")
    }
}

public class NullLogger: Logger {
    public init() {
    }

    public func log(logLevel: LogLevel, message: @autoclosure () -> String) {
    }
}

class FilteringLogger: Logger {
    private let minLogLevel: LogLevel
    private let logger: Logger

    init(minLogLevel: LogLevel, logger: Logger) {
        self.minLogLevel = minLogLevel
        self.logger = logger
    }

    func log(logLevel: LogLevel, message: @autoclosure () -> String) {
        if (logLevel.rawValue <= minLogLevel.rawValue) {
            logger.log(logLevel: logLevel, message: message())
        }
    }
}
