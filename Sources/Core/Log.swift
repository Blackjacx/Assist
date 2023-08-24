//
//  Log.swift
//  Core
//
//  Created by Stefan Herold on 24.08.23.
//

import Foundation
import OSLog

/// Represents the global logging system abstraction so we can hide the
/// specific logging system from the outside world.
///
/// If ever `Logger` gets renamed or we use a different framework behind we
/// don't need to change any code in our app (assuming log levels stay the
/// same).
///
/// Log levels we should use are:
/// - **info**: Call this function to capture information that may be helpful,
/// but isn’t essential, for troubleshooting.
/// - **debug**: Debug-level messages to use in a development environment while
/// actively debugging.
/// - **warning**: Warning-level messages for reporting unexpected non-fatal
/// failures.
/// - **error**: Error-level messages for reporting critical errors and failures.
/// - **fault**: Fault-level messages for capturing system-level or multi-process
/// errors only.
///
/// - note: Using the short name `Log` avoids long statements in code.
public enum Log {
    /// Using the bundle identifier is a great way to ensure a unique
    /// identifier.
    private static var subsystem = ProcessInfo.processId

    /*
     Generic
     */

    /// Generic Topics
    public static let generic = Logger(subsystem: subsystem, category: "GENERIC")

    /*
     Push
     */

    /// Push Command
    public static let push = Logger(subsystem: subsystem, category: "PUSH")

    /*
     Snap
     */

    /// Snap General
    public static let snap = Logger(subsystem: subsystem, category: "SNAP")
    /// Xcodebuild
    public static let xcodebuild = Logger(subsystem: subsystem, category: "XCODEBUILD")
    /// Mint
    public static let mint = Logger(subsystem: subsystem, category: "MINT")
    /// Simctl
    public static let simctl = Logger(subsystem: subsystem, category: "SIMCTL")
    /// Zip
    public static let zip = Logger(subsystem: subsystem, category: "ZIP")
}
