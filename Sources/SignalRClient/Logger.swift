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

/**
 Protocol for implementing loggers.
 */
public protocol Logger {
    /**
     Invoked by the client to write a log entry.

     - parameter logLevel: the log level of the entry to write
     - parameter message: log entry
    */
    func log(logLevel: LogLevel, message: @autoclosure () -> String)
}

public extension LogLevel {
    func toString() -> String {
        switch (self) {
        case .error: return "error"
        case .warning: return "warning"
        case .info: return "info"
        case .debug: return "debug"
        }
    }
}

/**
 Logger that log entries with the `print()` function.
 */
public class PrintLogger: Logger {
    let dateFormatter: DateFormatter

    /**
     Initializes a `PrintLogger`.
     */
    public init() {
        dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    }

    /**
     Writes log entries with the `print()` function.

     - parameter logLevel: the log level of the entry to write
     - parameter message: log entry
    */
    public func log(logLevel: LogLevel, message: @autoclosure () -> String) {
        print("\(dateFormatter.string(from: Date())) \(logLevel.toString()): \(message())")
    }
}

/**
 Logger that discards all log entries.
 */
public class NullLogger: Logger {
    /**
     Initializes a `NullLogger`.
    */
    public init() {
    }

    /**
     Discards all log entries.

     - parameter logLevel: ignored
     - parameter message: ignored
    */
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
