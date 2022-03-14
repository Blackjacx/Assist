//
//  Mint.swift
//  
//
//  Created by Stefan Herold on 24.09.20.
//

import Foundation
import SwiftShell

public struct Mint {

}

public extension Mint {

    static func screenshots(resultsBundleURL: URL, screensURL: URL) throws {
        let args = ["run", "ChargePoint/xcparse", "xcparse", "screenshots",
                    "--test-plan-config",
                    "--model", resultsBundleURL.path,
                    screensURL.path]

        let out = run("mint", args)

        if let error = out.error {
            Logger.shared.error(out.stderror)
            throw error
        }
    }
}
