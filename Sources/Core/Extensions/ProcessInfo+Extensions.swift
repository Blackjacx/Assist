//
//  ProcessInfo+Extensions.swift
//  Core
//
//  Created by Stefan Herold on 14.08.23.
//

import Foundation

public extension ProcessInfo {
    /// Returns a `String` representing the machine hardware name or nil if
    /// there was an error invoking `uname(_:)` or decoding the response.
    /// Return value is the equivalent to running `$ uname -m` in shell.
    static var machineHardwareName: String {
        get throws {
            var sysinfo = utsname()
            let code = uname(&sysinfo)
            guard code == EXIT_SUCCESS else {
                throw Error.exitWithErrorCode(code)
            }
            let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
            guard let identifier = String(bytes: data, encoding: .ascii) else {
                throw Error.invalidData(data)
            }
            return identifier.trimmingCharacters(in: .controlCharacters)
        }
    }

    private enum Error: Swift.Error {
        case exitWithErrorCode(_ code: Int32)
        case invalidData(_ data: Data)
    }
}
