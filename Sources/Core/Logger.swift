//
//  Logger.swift
//  Core
//
//  Created by Stefan Herold on 21.05.21.
//

import Foundation

public struct Logger {

    public static let shared = Logger()

    public func warn(_ closure: @autoclosure () -> Any?,
                     inset: Int = 0,
                     _ file: String = #filePath,
                     _ function: String = #function,
                     _ line: Int = #line) {
        log(level: .warn, inset: inset, file, function, line, closure)
    }

    public func info(_ closure: @autoclosure () -> Any?,
                     inset: Int = 0,
                     _ file: String = #filePath,
                     _ function: String = #function,
                     _ line: Int = #line) {
        log(level: .info, inset: inset, file, function, line, closure)
    }

    public func error(_ closure: @autoclosure () -> Any?,
                     inset: Int = 0,
                     _ file: String = #filePath,
                     _ function: String = #function,
                     _ line: Int = #line) {
        log(level: .error, inset: inset, file, function, line, closure)
    }

    private func log(level: Logger.Level, inset: Int, _ file: String, _ function: String, _ line: Int, _ closure: () -> Any?) {

        guard let closureResult = closure() else { return }

        let pathComponents: [String] = file.components(separatedBy: "/")
        let fileName = pathComponents.last?.replacingOccurrences(of: ".swift", with: "") ?? "Unknown File"
        let padding = String(repeating: " ", count: inset * 2)

        let message: String
        if Logger.verbose {
            message = "\(level.emoji) [\(Date())] \(fileName) in \(function) [\(line)]: \(closureResult)"
        } else {
            message = "\(level.emoji) [\(Date())]: \(closureResult)"
        }

        print("\(padding)\(message)")
    }
}

public extension Logger {

    enum Level: Int {
        case warn
        case info
        case error

        var name: String {
            switch self {
            case .warn: "Warn"
            case .info: "Info"
            case .error: "Error"
            }
        }

        var emoji: String {
            switch self {
            case .warn: "🟡"
            case .info: "🟢"
            case .error: "🔴"
            }
        }
    }

    /// The current log level, defaults to .info
    static var logLevel: Level = .info
    /// Enable to see additional information like sending object, date, function name, and line of code. Defaults to false.
    static var verbose = false
}
