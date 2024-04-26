//
//  LogMessage.swift
//  
//
//  Created by Wouter Hennen on 22/05/2023.
//

import OSLog
import ExternalAppLoggerHeaders

/// Represents a log message captured from the activity logs.
public struct LogMessage: Sendable {
    /// The log message string.
    public let message: String

    /// The date and time when the log message was captured.
    public let date: Date

    /// The subsystem associated with the log message, if available.
    public let subsystem: String?

    /// The category associated with the log message, if available.
    public let category: String?

    /// The type of the log message, indicating its severity level.
    public let type: OSLogType

    /// The name of the process that generated the log message.
    public let process: String

    /// The process identifier (PID) of the process that generated the log message.
    public let processID: pid_t
}

extension LogMessage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
        hasher.combine(date)
        hasher.combine(subsystem)
        hasher.combine(category)
        hasher.combine(type.rawValue)
        hasher.combine(process)
        hasher.combine(processID)
    }
}

extension LogMessage {
    init(_ event: _OSActivityLogMessageEvent) {
        self.init(
            message: event.eventMessage,
            date: event.timestamp,
            subsystem: event.subsystem,
            category: event.category,
            type: OSLogType(event.messageType),
            process: event.process,
            processID: event.processID
        )
    }
}

@objc
protocol _OSActivityLogMessageEvent {
    var eventMessage: String { get set }
    var timestamp: Date { get set }
    var subsystem: String? { get set }
    var category: String? { get set }
    var messageType: UInt8 { get set }
    var process: String { get set }
    var processID: pid_t { get set }

    init(entry: UnsafeMutablePointer<os_activity_stream_entry_s>)
}
