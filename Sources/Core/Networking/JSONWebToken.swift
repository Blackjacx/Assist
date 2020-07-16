//
//  JWT.swift
//  ASC
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation
import SwiftJWT

public struct JSONWebToken {

    public static func token() throws -> String {

        let env = ProcessInfo.processInfo.environment

        guard let keyFile = env["ASC_AUTH_KEY"], !keyFile.isEmpty else {
            throw Error.environmentVariableNotAvailable("ASC_AUTH_KEY")
        }

        guard let kid = env["ASC_AUTH_KEY_ID"], !kid.isEmpty else {
            throw Error.environmentVariableNotAvailable("ASC_AUTH_KEY_ID")
        }

        guard let iss = env["ASC_AUTH_KEY_ISSUER_ID"], !iss.isEmpty else {
            throw Error.environmentVariableNotAvailable("ASC_AUTH_KEY_ISSUER_ID")
        }

        let header = Header(kid: kid)
        let claims = JWTClaims(iss: iss,
                               exp: Date(timeIntervalSinceNow: 20 * 60),
                               aud: "appstoreconnect-v1",
                               alg: "ES256")

        var jwt =  JWT(header: header, claims: claims)

        guard let keyData = FileManager.default.contents(atPath: keyFile) else {
            throw Error.fileNotFound(keyFile)
        }

        let signer = JWTSigner.es256(privateKey: keyData)
        let signedJwt = try jwt.sign(using: signer)
        return signedJwt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension JSONWebToken {

    enum Error: Swift.Error {
        case environmentVariableNotAvailable(String)
        case unableToConstructJWT
        case fileNotFound(String)
    }
}

private struct JWTClaims: Claims {
    var iss: String
    var exp: Date?
    var aud: String
    var alg: String
}
