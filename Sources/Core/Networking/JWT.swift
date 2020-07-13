//
//  JWT.swift
//  ASC
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation

public struct JWT {

    public static let token: String? = {

        let env = ProcessInfo.processInfo.environment

        guard
            let key = env["ASC_AUTH_KEY"],
            let id = env["ASC_AUTH_KEY_ID"],
            let iid = env["ASC_AUTH_KEY_ISSUER_ID"],
            let scriptPath = env["ASC_AUTH_JWT_SCRIPT_PATH"],
            let token = Command.execute(cmd: scriptPath, args: [key, id, iid]) else {
                return nil
        }
        return token.trimmingCharacters(in: .whitespacesAndNewlines)
    }()
}
