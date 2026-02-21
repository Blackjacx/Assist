//
//  Mint.swift
//  
//
//  Created by Stefan Herold on 24.09.20.
//

import Foundation
import os
import SwiftShell

public struct Mint {

}

public extension Mint {

    static func screenshots(resultsBundleURL: URL, screensURL: URL) throws {
        let args = ["run", "ChargePoint/xcparse", "xcparse", "screenshots",
                    "--test-plan-config",
                    "--model",
                    "--verbose",
                    resultsBundleURL.path,
                    screensURL.path]

        let out = run("mint", args)

        if let error = out.error {
            Log.mint.error("\(out.stderror, privacy: .public)")
            throw error
        }
    }
}
