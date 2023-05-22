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
    ///   - pid: The process identifier (PID) of the target process.
    ///   - flags: The options specifying the behavior of the activity stream. Default value is `[.historical, .processOnly]`.
    /// - Returns: An `AsyncStream` that emits `LogMessage` objects representing the activity logs.
    ///
    /// The `logs(for:flags:)` method retrieves activity logs for a specific process identified by its PID. It returns an `AsyncStream`
    /// that emits `LogMessage` objects representing the activity logs for the process. 
    ///
    /// Usage Example:
    ///
    /// ```swift
    /// let pid: pid_t = ... // Specify the process identifier
    /// let logStream = LogStream.logs(for: pid)
    ///
    /// Task {
    ///     for await log in logStream {
    ///         // Process the log message
    ///         print(log)
    ///     }
    /// }
    /// ```
    public static func logs(for pid: pid_t, flags: ActivityStreamOptions = [.historical, .processOnly]) -> AsyncStream<LogMessage> {
        return AsyncStream { cont in

            let stream = streamLog(pid: pid, flags: flags.rawValue) { entryPointer, error in

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
                
                cont.yield(logMessage)
                return true
            }

            cont.onTermination = { _ in
                cancelLog(stream: stream)
            }

            resumeLog(stream: stream)
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
