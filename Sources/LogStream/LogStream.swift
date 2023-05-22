//
//  LogStream.swift
//  
//
//  Created by Wouter Hennen on 22/05/2023.
//

import ExternalAppLoggerHeaders

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
    public static func logs(for processID: pid_t, flags: ActivityStreamOptions = [.historical, .processOnly]) -> AsyncStream<LogMessage> {
        return AsyncStream { continuation in

            let stream = createStream(pid: processID, flags: flags, continuation: continuation)

            continuation.onTermination = { _ in
                cancelLog(stream: stream)
            }

            resumeLog(stream: stream)
        }
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
    public static func logs(for processIDs: [pid_t], flags: ActivityStreamOptions = [.historical, .processOnly]) -> AsyncStream<LogMessage> {
        AsyncStream { continuation in
            let streams = processIDs.map {
                createStream(pid: $0, flags: flags, continuation: continuation)
            }

            continuation.onTermination = { _ in
                streams.forEach(cancelLog)
            }

            streams.forEach(resumeLog)
        }
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
    public static func logs(flags: ActivityStreamOptions = [.historical, .processOnly]) -> AsyncStream<LogMessage> {
        LogStream.logs(for: -1, flags: flags)
    }

    static func createStream(pid: pid_t, flags: ActivityStreamOptions, continuation: AsyncStream<LogMessage>.Continuation) -> ActivityStream? {
        streamLog(pid: pid, flags: flags.rawValue) { entryPointer, error in

            guard error == 0, let entryPointer else { return false }

            let entry = entryPointer.pointee

            guard entry.type == OS_ACTIVITY_STREAM_TYPE_LOG_MESSAGE || entry.type == OS_ACTIVITY_STREAM_TYPE_LEGACY_LOG_MESSAGE else { return true }

            let event = OSActivityLogMessageEvent(entry: entryPointer)

            let logMessage = LogMessage(
                message: event.eventMessage,
                date: event.timestamp,
                subsystem: event.subsystem,
                category: event.category,
                type: .init(event.messageType),
                process: event.process,
                processID: event.processID
            )

            continuation.yield(logMessage)
            return true
        }
    }
}

typealias ActivityStream = os_activity_stream_t

@_silgen_name("os_activity_stream_for_pid")
fileprivate func streamLog(
    pid: pid_t,
    flags: ActivityStreamOptions.RawValue,
    stream_block: (@convention(block) (os_activity_stream_entry_t?, Int32) -> Bool)?
) -> ActivityStream?

@_silgen_name("os_activity_stream_resume")
fileprivate func resumeLog(stream: ActivityStream?)

@_silgen_name("os_activity_stream_cancel")
fileprivate func cancelLog(stream: ActivityStream?)
