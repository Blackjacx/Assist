//
//  CommandExecution.swift
//  ASC
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation

public struct Command {

    static let bash: CommandExecutable = Bash()

    public enum Shell {
        case bash
    }

    public static func execute(cmd: String, args: [String] = [], shell: Shell = .bash) -> String? {

        switch shell {
        case .bash: return Self.bash.execute(cmd: cmd, args: args)
        }
    }
}

public protocol CommandExecutable {
    func execute(cmd: String, args: [String]) -> String?
}



final class Bash: CommandExecutable {

    // MARK: - CommandExecutable

    func execute(cmd: String, args: [String]) -> String? {
        guard var bashCommand = execute(command: "/bin/bash" , arguments: ["-l", "-c", "which \(cmd)"]) else { return "\(cmd) not found" }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return execute(command: bashCommand, arguments: args)
    }

    // MARK: Private

    private func execute(command: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        return output
    }
}
