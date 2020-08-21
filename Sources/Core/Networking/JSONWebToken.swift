//
//  JWT.swift
//  Core
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation
import SwiftJWT

public struct JSONWebToken {

    public static func tokenAsc() throws -> String {

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

    public static func tokenApns(credentials: JWTApnsCredentials) throws -> String {

        let header = Header(kid: credentials.keyId)
        let claims = JWTClaimsApns(iss: credentials.issuerId)

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

    /// https://github.com/googleapis/google-auth-library-swift/blob/f3c652646735e27885e81e710d4147f33eb6c26f/Sources/OAuth2/ServiceAccountTokenProvider/ServiceAccountTokenProvider.swift
    /// https://medium.com/rocket-fuel/getting-started-with-firebase-for-server-side-swift-93c11098702a
    /// https://stackoverflow.com/questions/46396224/how-do-i-generate-an-auth-token-using-jwt-for-google-firebase
    public static func tokenFcm(credentials: JWTFcmCredentials) throws -> String {

        let header = Header()
        let scope = "https://www.googleapis.com/auth/firebase.messaging"
        let claims = JWTClaimsFcm(clientEmail: credentials.clientEmail, tokenUrl: credentials.tokenUrl, scope: scope)

        var jwt = JWT(header: header, claims: claims)

        guard let privateKeyData = credentials.privateKey.data(using: .utf8) else {
            throw JSONWebToken.Error.privateKeyInvalid
        }

        guard privateKeyData.count > 0 else {
            throw JSONWebToken.Error.privateKeyEmpty
        }

        let signer = JWTSigner.rs256(privateKey: privateKeyData)
        let signedJwt = try jwt.sign(using: signer)

        //
        // With the signed JWT we have to make another sync request to 
        // Google which gives us the token we use to send the push.
        //

        let jsonData = try JSONSerialization.data(withJSONObject: [
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": signedJwt
          ]
        )
  
        var urlRequest = URLRequest(url: URL(string: credentials.tokenUrl)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")
    
        let session = URLSession(configuration: .default)
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<String, Swift.Error>!
        session.dataTask(with:urlRequest) {(data, response, error) -> Void in
          if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data {
            do {
              let token = try Json.decoder.decode(JWTFcmCredentials.Token.self, from: data).accessToken
              result = .success(token)
            } catch {
              result = .failure(error)
            }
          } else {
            result = .failure(error!)
          }
          semaphore.signal()
        }.resume()
        
        semaphore.wait()
        return try result.get()
    }
}

public extension JSONWebToken {

    enum Error: Swift.Error {
        case credentialsNotSet
        case environmentVariableNotAvailable(String)
        case unableToConstructJWT
        case fileNotFound(String)
        case privateKeyInvalid
        case privateKeyEmpty
        case keyContainsNoData(String)
        case googleServiceAccountJsonNotFound(path: String)
    }
}

private struct JWTClaimsAsc: Claims {
    let iss: String
    let exp: Date?
    let aud: String
    let alg: String
}

public struct JWTApnsCredentials {

    public var keyPath: String
    public var keyId: String
    public var issuerId: String

    public init(keyPath: String, keyId: String, issuerId: String) {
      self.keyPath = keyPath
      self.keyId = keyId
      self.issuerId = issuerId
    }
}

private struct JWTClaimsApns: Claims {
    let iss: String
    let iat: Date? = Date()
    let alg: String = "ES256"
}

public struct JWTFcmCredentials: Codable {

    public var privateKey: String
    public var clientEmail: String
    public var tokenUrl: String
    public var projectId: String

    public init(privateKey: String, clientEmail: String, tokenUrl: String, projectId: String) {
      self.privateKey = privateKey
      self.clientEmail = clientEmail
      self.tokenUrl = tokenUrl
      self.projectId = projectId
    }

    enum CodingKeys: String, CodingKey {
      case privateKey = "private_key"
      case clientEmail = "client_email"
      case tokenUrl = "token_uri"
      case projectId = "project_id"
    }

    struct Token: Codable {
      var accessToken: String

      enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
      }
    }
}

private struct JWTClaimsFcm: Claims {

    let iss: String
    let sub: String
    let iat: Date?
    let exp: Date?
    let aud: String?
    let scope: String?

    init(clientEmail: String, tokenUrl: String, scope: String) {
      self.iss = clientEmail
      self.sub = clientEmail
      self.aud = tokenUrl
      self.scope = scope

      let now: Date = Date()
      iat = now
      exp = now.addingTimeInterval(3600)
    }
}
