# LogStream

This package provides some utilities to capture logs of other processes. This can be useful when working with extensions using [ExtensionKit](https://developer.apple.com/documentation/extensionkit).

The logs captured are the same ones visible in Console.app.

## Usage

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


