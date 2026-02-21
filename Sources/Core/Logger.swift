//
//  Logger.swift
//  Core
//
//  Created by Stefan Herold on 21.05.21.
//

import Foundation
import os

public struct Logger {

    public static let shared = Logger()

    private let osLog = os.Logger(
        subsystem: "com.blackjacx.assist",
        category: "default",
    )

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

public extension Logger {

    enum Level: Int {
        case warn
        case info
        case error
    }
}
