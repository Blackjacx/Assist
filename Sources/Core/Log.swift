//
//  Logger.swift
//  Core
//
//  Created by Stefan Herold on 21.05.21.
//

import Foundation
import os

public struct Log {

    private static let subsystem = "com.blackjacx.assist"

    public static let simctl = Log(category: "simctl")
    public static let xcodebuild = Log(category: "xcodebuild")
    public static let mint = Log(category: "mint")
    public static let zip = Log(category: "zip")
    public static let snap = Log(category: "snap")
    public static let asc = Log(category: "asc")
    public static let push = Log(category: "push")

    private let osLog: os.Logger

    private init(category: String) {
        osLog = os.Logger(subsystem: Self.subsystem, category: category)
    }

    public func warn(
        _ closure: @autoclosure () -> Any?,
        _ file: String = #filePath,
        _ function: String = #function,
        _ line: Int = #line,
    ) {
        guard let result = closure() else { return }
        let message = "\(result)"
        osLog.warning("\(message, privacy: .public)")
        fputs("Warning: \(message)\n", stderr)
    }

    public func info(
        _ closure: @autoclosure () -> Any?,
        _ file: String = #filePath,
        _ function: String = #function,
        _ line: Int = #line,
    ) {
        guard let result = closure() else { return }
        let message = "\(result)"
        osLog.info("\(message, privacy: .public)")
        print(message)
    }

    public func error(
        _ closure: @autoclosure () -> Any?,
        _ file: String = #filePath,
        _ function: String = #function,
        _ line: Int = #line,
    ) {
        guard let result = closure() else { return }
        let message = "\(result)"
        osLog.error("\(message, privacy: .public)")
        fputs("Error: \(message)\n", stderr)
    }
}

public extension Log {

    enum Level: Int {
        case warn
        case info
        case error
    }
}
