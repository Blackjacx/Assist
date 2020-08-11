//
//  JWT.swift
//  ASC
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation
import SwiftJWT

public struct JSONWebToken {

    public enum UseCase {
      /// App Store Connect
      case asc
      /// Apple Push Notification Service
      case apns
    }

    public static func token(useCase: UseCase, credentials: JSONWebTokenCredentials? = nil) throws -> String {
      switch useCase {
        case .asc: return try tokenAsc()
        case .apns: 
          guard let credentials = credentials else {
              throw JSONWebToken.Error.credentialsNotSet
          }
          return try tokenApns(credentials: credentials)
      }
    }

    private static func tokenAsc() throws -> String {

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
        let claims = JWTClaimsAsc(iss: iss,
                                  exp: Date(timeIntervalSinceNow: 20 * 60),
                                  aud: "appstoreconnect-v1",
                                  alg: "ES256")

        var jwt =  JWT(header: header, claims: claims)

        guard let keyData = FileManager.default.contents(atPath: keyFile) else {
            throw Error.fileNotFound(keyFile)
        }

        let signer = JWTSigner.es256(privateKey: keyData)
        let signedJwt = try jwt.sign(using: signer).trimmingCharacters(in: .whitespacesAndNewlines)
        return signedJwt
    }

    private static func tokenApns(credentials: JSONWebTokenCredentials) throws -> String {

        let header = Header(kid: credentials.keyId)
        let claims = JWTClaimsApns(iss: credentials.issuerId, iat: Date(), alg: "ES256")

        var jwt =  JWT(header: header, claims: claims)

        guard let keyData = FileManager.default.contents(atPath: credentials.keyPath) else {
            throw JSONWebToken.Error.fileNotFound(credentials.keyPath)
        }

        guard keyData.count > 0 else {
            throw JSONWebToken.Error.keyContainsNoData(credentials.keyPath)
        }

        let signer = JWTSigner.es256(privateKey: keyData)
        let signedJwt = try jwt.sign(using: signer).trimmingCharacters(in: .whitespacesAndNewlines)
        return signedJwt
    }
}

extension JSONWebToken {

    enum Error: Swift.Error {
        case credentialsNotSet
        case environmentVariableNotAvailable(String)
        case unableToConstructJWT
        case fileNotFound(String)
        case keyContainsNoData(String)
    }
}

private struct JWTClaimsAsc: Claims {
    let iss: String
    let exp: Date?
    let aud: String
    let alg: String
}

private struct JWTClaimsApns: Claims {
    let iss: String
    let iat: Date?
    let alg: String
}
