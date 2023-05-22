// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogStream",
    platforms: [
        .macOS(.v10_15),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "LogStream",
            targets: ["LogStream"]),
    ],
    targets: [
        .target(
            name: "LogStream",
            dependencies: ["ExternalAppLoggerHeaders"]
        ),
        
        .target(
            name: "ExternalAppLoggerHeaders",
            path: "Sources/Headers",
            linkerSettings: [
                .linkedFramework("LoggingSupport")
            ]
        )
    ]
)
