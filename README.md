# LogStream

This package provides some utilities to capture logs of other processes. This can be useful when working with extensions using [ExtensionKit](https://developer.apple.com/documentation/extensionkit).

The logs captured are the same ones visible in Console.app.

> [!IMPORTANT]
> This package makes use of the private framework LoggingSupport. While unlikely, OS updates might change the internals of the framework and break this package.

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
