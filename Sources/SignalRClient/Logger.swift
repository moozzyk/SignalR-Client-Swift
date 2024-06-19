//
//  Logger.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 8/2/18.
//  Copyright © 2018 Pawel Kadluczka. All rights reserved.
//

import OSLog
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
public protocol LoggerProtocol {
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
public class PrintLogger: LoggerProtocol {
    let dateFormatter: DateFormatter
    
    private let logger = Logger(
        subsystem: "ru.medsi.smartmed.dev",
        category: "SignalR"
    )
    
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
    public func log(
        logLevel: LogLevel,
        message: @autoclosure () -> String
    ) {
        let logMessage = "\(self.dateFormatter.string(from: Date())) \(logLevel.toString()): \(message())"
        
        logger.log(
            level: .info,
            "\(logMessage)"
        )
        
        print(logMessage)
    }
}

/**
 Logger that discards all log entries.
 */
public class NullLogger: LoggerProtocol {
    /**
     Initializes a `NullLogger`.
    
    */
    
    private let logger = Logger(
        subsystem: "ru.medsi.smartmed.dev",
        category: "SignalR"
    )
    
    public init() {
        dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    }
    
    let dateFormatter: DateFormatter

    /**
     Discards all log entries.

     - parameter logLevel: ignored
     - parameter message: ignored
    */
    public func log(logLevel: LogLevel, message: @autoclosure () -> String) {
        let logMessage = "\(self.dateFormatter.string(from: Date())) \(logLevel.toString()): \(message())"
        
        logger.log(
            level: .info,
            "\(logMessage)"
        )
        
    }
}

class FilteringLogger: LoggerProtocol {
    private let minLogLevel: LogLevel
    private let logger: LoggerProtocol

    init(minLogLevel: LogLevel, logger: LoggerProtocol) {
        self.minLogLevel = minLogLevel
        self.logger = logger
    }

    func log(logLevel: LogLevel, message: @autoclosure () -> String) {
        if (logLevel.rawValue <= minLogLevel.rawValue) {
            logger.log(logLevel: logLevel, message: message())
        }
    }
}
