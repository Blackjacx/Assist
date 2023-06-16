//
//  Xcodebuild.swift
//  
//
//  Created by Stefan Herold on 23.09.20.
//

import Foundation
import SwiftShell

public struct Xcodebuild {
}

public extension Xcodebuild {

    enum Command: String {
        case buildForTesting = "build-for-testing"
        case testWithoutBuilding = "test-without-building"
    }
    
    static func execute(cmd: Command,
                        workspace: String,
                        schemes: [String],
                        deviceIds: [String],
                        testPlan: String? = nil,
                        resultsBundleURL: URL? = nil) throws {

        let destinations = deviceIds.map { "platform=iOS Simulator,id=\($0)" }

        for scheme in schemes {
            var args = ["xcodebuild", cmd.rawValue, "-workspace", workspace, "-scheme", scheme]
            destinations.forEach { args += ["-destination", $0] }

            if let testPlan {
                args += ["-testPlan", testPlan]
            }

            if let resultsBundleURL {
                args += ["-resultBundlePath", resultsBundleURL.path]
            }

            let out = run("xcrun", args)
            
            if let error = out.error {
                Logger.shared.error(out.stderror)
                throw error
            }
        }
    }
}
