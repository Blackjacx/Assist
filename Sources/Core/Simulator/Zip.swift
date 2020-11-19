//
//  Zip.swift
//
//
//  Created by Stefan Herold on 24.09.20.
//

import Foundation
import SwiftShell

public struct Zip {

}

public extension Zip {

    static func zip(outFile: String, relativeTargetFolder: String, excludePattern: String? = nil) throws {
        var args = ["-r0",
                    outFile,
                    relativeTargetFolder]

        if let excludePattern = excludePattern {
            args += ["-x", excludePattern]
        }

        let out = run("zip", args)

        if let error = out.error {
            print(out.stderror)
            throw error
        }
    }
}
