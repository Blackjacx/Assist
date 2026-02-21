//
//  Log.swift
//  Core
//
//  Created by Stefan Herold on 21.05.21.
//

import os

/// Namespace providing per-tool `os.Logger` instances for structured,
/// category-filtered logging via the unified logging system.
///
/// Use the appropriate category for each tool so log output can be filtered
/// independently in Console.app or via `log stream`:
/// ```
/// log stream --predicate 'process == "snap" AND category == "simctl"'
/// ```
///
/// Privacy is controlled per log statement at the call site:
/// ```swift
/// Log.snap.info("Finding runtime for platform \(runtimeName, privacy: .public)")
/// Log.simctl.error("\(out.stderror, privacy: .public)")
/// ```
public enum Log {

    private static let subsystem = "com.blackjacx.assist"

    public static let simctl = os.Logger(subsystem: subsystem, category: "simctl")
    public static let xcodebuild = os.Logger(subsystem: subsystem, category: "xcodebuild")
    public static let mint = os.Logger(subsystem: subsystem, category: "mint")
    public static let zip = os.Logger(subsystem: subsystem, category: "zip")
    public static let snap = os.Logger(subsystem: subsystem, category: "snap")
    public static let asc = os.Logger(subsystem: subsystem, category: "asc")
    public static let push = os.Logger(subsystem: subsystem, category: "push")
}
