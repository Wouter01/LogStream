//
//  ActivityStream.swift
//  
//
//  Created by Wouter Hennen on 22/05/2023.
//

/// Options for configuring the behavior of an activity stream.
public struct ActivityStreamOptions: OptionSet, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public extension ActivityStreamOptions {
    static let processOnly = ActivityStreamOptions(rawValue: 1 << 0)
    static let skipDecode = ActivityStreamOptions(rawValue: 1 << 1)
    static let payload = ActivityStreamOptions(rawValue: 1 << 2)
    static let historical = ActivityStreamOptions(rawValue: 1 << 3)
    static let callStack = ActivityStreamOptions(rawValue: 1 << 4)
    static let debug = ActivityStreamOptions(rawValue: 1 << 5)
    static let buffered = ActivityStreamOptions(rawValue: 1 << 6)
    static let noSensitive = ActivityStreamOptions(rawValue: 1 << 7)
    static let info = ActivityStreamOptions(rawValue: 1 << 8)
    static let promiscuous = ActivityStreamOptions(rawValue: 1 << 9)
    static let preciseTimestamps = ActivityStreamOptions(rawValue: 1 << 9)

    static let `default`: ActivityStreamOptions = [.historical, .processOnly]
}
