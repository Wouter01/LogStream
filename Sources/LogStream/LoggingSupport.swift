//
//  LoggingSupport.swift
//  
//
//  Created by Wouter on 26/4/24.
//

import Foundation
import ExternalAppLoggerHeaders

enum LoggingSupport {
    nonisolated(unsafe) static let handle = dlopen("/System/Library/PrivateFrameworks/LoggingSupport.framework/LoggingSupport", RTLD_LAZY),
                            streamLog = unsafeBitCast(dlsym(handle, "os_activity_stream_for_pid"), to: StreamLog.self),
                            resumeLog = unsafeBitCast(dlsym(handle, "os_activity_stream_resume"), to: ResumeLog.self),
                            cancelLog = unsafeBitCast(dlsym(handle, "os_activity_stream_cancel"), to: CancelLog.self)

    typealias StreamLog = @convention(c) (
        pid_t,
        ActivityStreamOptions.RawValue,
        (@convention(block) (os_activity_stream_entry_t?, Int32) -> Bool)?
    ) -> ActivityStream?

    typealias ResumeLog = @convention(c) (ActivityStream?) -> Void

    typealias CancelLog = ResumeLog

    typealias ActivityStream = OpaquePointer

}
