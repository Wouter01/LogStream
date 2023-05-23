# LogStream

This package provides some utilities to capture logs of other processes. This can be useful when working with extensions using [ExtensionKit](https://developer.apple.com/documentation/extensionkit).

The logs captured are the same ones visible in Console.app.

## Usage

Capturing logs for one process:

```swift
// Specify the process identifier of which to capture logs.
let pid: pid_t = ...
let logStream = LogStream.logs(for: pid)

Task {
    for await log in logStream {
        print("\(log.process) says: \(log.message)")
    }
}
```

Logs of multiple processes can also be captures with another initializer:
```swift
public static func logs(for processIDs: [pid_t], flags: ActivityStreamOptions) -> AsyncStream<LogMessage>
```

To capture logs of all processes, use the following initializer:
```swift
public static func logs(flags: ActivityStreamOptions) -> AsyncStream<LogMessage>
```

> Note: To link against the private framework LoggingSupport, which is used by this package, you may be required to set an extra search path. You can do this by adding the following to `System Framework Search Paths` in your projects build settings: `$(DEVELOPER_SDK_DIR)/MacOSX.sdk/System/Library/PrivateFrameworks`
