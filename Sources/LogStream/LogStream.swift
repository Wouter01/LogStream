//
//  LogStream.swift
//  
//
//  Created by Wouter Hennen on 22/05/2023.
//

import ExternalAppLoggerHeaders
import Foundation

public enum LogStream {

    /// Retrieve activity logs for a specific process identifier (PID) using an asynchronous stream.
    ///
    /// - Parameters:
    ///   - processID: The process identifier (PID) of the target process.
    ///   - flags: The options specifying the behavior of the activity stream. Default value is `[.historical, .processOnly]`.
    /// - Returns: An `AsyncStream` that emits `LogMessage` objects representing the activity logs.
    ///
    /// Usage Example:
    ///
    /// ```swift
    /// let pid: pid_t = ... // Specify the process identifier
    /// let logStream = LogStream.logs(for: pid)
    ///
    /// Task {
    ///     for await log in logStream {
    ///         print("\(log.process) says:", log.message)
    ///     }
    /// }
    /// ```
    public static func logs(for processID: pid_t, flags: ActivityStreamOptions = .default) -> AsyncStream<LogMessage> {

        let (stream, continuation) = AsyncStream.makeStream(of: LogMessage.self)

        let logstream = createStream(pid: processID, flags: flags, continuation: continuation)

        continuation.onTermination = { _ in
            LoggingSupport.cancelLog(logstream)
        }

        LoggingSupport.resumeLog(logstream)

        return stream
    }

    /// Retrieve activity logs for a selection of processes using an asynchronous stream.
    ///
    /// - Parameters:
    ///   - processIDs: A list of process identifiers (PID) of the desired target processes.
    ///   - flags: The options specifying the behavior of the activity stream. Default value is `[.historical, .processOnly]`.
    /// - Returns: An `AsyncStream` that emits `LogMessage` objects representing the activity logs.
    ///
    /// Usage Example:
    ///
    /// ```swift
    /// Task {
    ///     let pids: [pid_t] = ... // Specify the process identifiers
    ///     for await log in LogStream.logs(for: pids) {
    ///         print("\(log.process) says:", log.message)
    ///     }
    /// }
    /// ```
    public static func logs(for processIDs: [pid_t], flags: ActivityStreamOptions = .default) -> AsyncStream<LogMessage> {
        let (stream, continuation) = AsyncStream.makeStream(of: LogMessage.self)

        let logstreams = processIDs.map {
            createStream(pid: $0, flags: flags, continuation: continuation)
        }

        continuation.onTermination = { _ in
            logstreams.forEach(LoggingSupport.cancelLog)
        }

        logstreams.forEach(LoggingSupport.resumeLog)

        return stream
    }

    /// Retrieve activity logs for all processes using an asynchronous stream.
    ///
    /// - Parameters:
    ///   - flags: The options specifying the behavior of the activity stream. Default value is `[.historical, .processOnly]`.
    /// - Returns: An `AsyncStream` that emits `LogMessage` objects representing the activity logs.
    ///
    /// Usage Example:
    ///
    /// ```swift
    /// Task {
    ///     for await log in LogStream.logs(for: ) {
    ///         print("\(log.process) says:", log.message)
    ///     }
    /// }
    /// ```
    public static func logs(flags: ActivityStreamOptions = .default) -> AsyncStream<LogMessage> {
        LogStream.logs(for: -1, flags: flags)
    }

    static let messageClass = unsafeBitCast(NSClassFromString("OSActivityLogMessageEvent"), to: _OSActivityLogMessageEvent.Type.self)

    static func createStream(
        pid: pid_t,
        flags: ActivityStreamOptions,
        continuation: AsyncStream<LogMessage>.Continuation
    ) -> LoggingSupport.ActivityStream? {
        LoggingSupport.streamLog(pid, flags.rawValue) { entryPointer, error in
            guard error == 0, let entryPointer else { return false }

            let entry = entryPointer.pointee

            guard
                entry.type == OS_ACTIVITY_STREAM_TYPE_LOG_MESSAGE || entry.type == OS_ACTIVITY_STREAM_TYPE_LEGACY_LOG_MESSAGE
            else { return true }

            let event = messageClass.init(entry: entryPointer)

            continuation.yield(LogMessage(event))
            return true
        }
    }
}
