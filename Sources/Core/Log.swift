//
//  Log.swift
//  Core
//
//  Created by Stefan Herold on 21.05.21.
//

import os

/// A logging category that writes to both the unified logging system
/// (Console.app / `log stream`) and the terminal (stdout/stderr).
///
/// Access via the static instances on `Log`:
/// ```swift
/// Log.snap.info("Finding runtime for platform \(runtimeName)")
/// Log.simctl.error(out.stderror)
/// ```
///
/// Filter by subsystem/category in the terminal:
/// ```shell
/// log stream --predicate 'process == "snap" AND category == "simctl"' --level debug
/// ```
public struct Log {

    public static let simctl    = Log(category: "simctl")
    public static let xcodebuild = Log(category: "xcodebuild")
    public static let mint      = Log(category: "mint")
    public static let zip       = Log(category: "zip")
    public static let snap      = Log(category: "snap")
    public static let asc       = Log(category: "asc")
    public static let push      = Log(category: "push")

    private static let subsystem = "com.blackjacx.assist"
    private let logger: os.Logger

    private init(category: String) {
        logger = os.Logger(subsystem: Self.subsystem, category: category)
    }

    public func info(_ message: @autoclosure () -> String) {
        let msg = message()
        logger.info("\(msg, privacy: .public)")
        print(msg)
    }

    public func warning(_ message: @autoclosure () -> String) {
        let msg = message()
        logger.warning("\(msg, privacy: .public)")
        fputs("Warning: \(msg)\n", stderr)
    }

    public func error(_ message: @autoclosure () -> String) {
        let msg = message()
        logger.error("\(msg, privacy: .public)")
        fputs("Error: \(msg)\n", stderr)
    }
}
