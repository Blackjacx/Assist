//
//  FileManager+Extensions.swift
//  
//
//  Created by Stefan Herold on 24.09.20.
//

import Foundation

public extension FileManager {

    static func createTemporaryDirectory() throws -> URL {
        let uuid = "com.stherold.\(ProcessInfo.processInfo.processName).\(NSUUID().uuidString)"
        let tmpDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(uuid)
        try FileManager.default.createDirectory(at: tmpDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        return tmpDirectoryURL
    }
}
