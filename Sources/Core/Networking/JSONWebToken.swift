//
//  JSONWebToken.swift
//  Core
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation
import Engine
import JWTKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct JSONWebToken {

    public enum Service {
        case apns(credentials: JWTApnsCredentials)
        case fcm(credentials: JWTFcmCredentials)
    }

    public enum Error: Swift.Error {
        case credentialsNotSet
        case unableToConstructJWT
        case fileNotFound(String)
        case privateKeyInvalid
        case privateKeyEmpty
        case keyContainsNoData(String)
        case googleServiceAccountJsonNotFound(path: String)
        case invalidResonse(response: URLResponse)
    }

    public static func token(for service: Service) async throws -> String {

        switch service {
        case .apns(let credentials): return try token(credentials: credentials)
        case .fcm(let credentials): return try await token(credentials: credentials)
        }
    }

    private static func token(credentials: JWTApnsCredentials) throws -> String {

        let claims = JWTClaimsApns(iss: credentials.issuerId)
        let signers = JWTSigners()

        guard let keyData = FileManager.default.contents(atPath: credentials.keyPath) else {
            throw JSONWebToken.Error.fileNotFound(credentials.keyPath)
        }

        guard keyData.count > 0 else {
            throw JSONWebToken.Error.keyContainsNoData(credentials.keyPath)
        }

        try signers.use(.es256(key: .private(pem: keyData)))
        let jwt = try signers.sign(claims, kid: JWKIdentifier(string: credentials.keyId)).trimmingCharacters(in: .whitespacesAndNewlines)
        return jwt
    }

    /// https://github.com/googleapis/google-auth-library-swift/blob/f3c652646735e27885e81e710d4147f33eb6c26f/Sources/OAuth2/ServiceAccountTokenProvider/ServiceAccountTokenProvider.swift
    /// https://medium.com/rocket-fuel/getting-started-with-firebase-for-server-side-swift-93c11098702a
    /// https://stackoverflow.com/questions/46396224/how-do-i-generate-an-auth-token-using-jwt-for-google-firebase
    private static func token(credentials: JWTFcmCredentials) async throws -> String {

        let claims = JWTClaimsFcm(iss: credentials.clientEmail,
                                  sub: credentials.clientEmail,
                                  scope: "https://www.googleapis.com/auth/firebase.messaging",
                                  aud: credentials.tokenUrl)

        guard let keyData = credentials.privateKey.data(using: .utf8) else {
            throw JSONWebToken.Error.privateKeyInvalid
        }

        guard keyData.count > 0 else {
            throw JSONWebToken.Error.privateKeyEmpty
        }

        let signer = try JWTSigner.rs256(key: .private(pem: keyData))
        let jwt = try signer.sign(claims)

        //
        // With the signed JWT we have to make another request to Google which gives us the token we use to send the
        // push message.
        //

        let jsonData = try JSONSerialization.data(withJSONObject: [
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": jwt
        ]
        )

        var urlRequest = URLRequest(url: URL(string: credentials.tokenUrl)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")

        let session = URLSession(configuration: .default)
        let (data, response) = try await session.data(for: urlRequest, delegate: nil)

        guard let httpResponse = response as? HTTPURLResponse, (200...399).contains(httpResponse.statusCode) else {
            throw JSONWebToken.Error.invalidResonse(response: response)
        }

        return try Json.decoder.decode(JWTFcmCredentials.Token.self, from: data).accessToken
    }
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

private struct JWTClaimsApns: JWTPayload {
    var iss: String
    var iat: Date? = Date()
    var alg: String = "ES256"

    func verify(using signer: JWTSigner) throws {}
}

public struct JWTFcmCredentials: Codable {

    public var privateKey: String
    public var privateKeyId: String
    public var clientEmail: String
    public var tokenUrl: String
    public var projectId: String

    public init(privateKey: String, privateKeyId: String, clientEmail: String, tokenUrl: String, projectId: String) {
        self.privateKey = privateKey
        self.privateKeyId = privateKeyId
        self.clientEmail = clientEmail
        self.tokenUrl = tokenUrl
        self.projectId = projectId
    }

    enum CodingKeys: String, CodingKey {
        case privateKey = "private_key"
        case privateKeyId = "private_key_id"
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

private struct JWTClaimsFcm: JWTPayload {
    var uid: String = UUID().uuidString
    
    var exp: ExpirationClaim
    var iat: IssuedAtClaim
    var iss: IssuerClaim
    var sub: SubjectClaim
    var scope: String
    var aud: AudienceClaim

    init(iss: String, sub: String, scope: String, aud: String) {
        let now: Date = Date()

        self.exp = ExpirationClaim(value: now.addingTimeInterval(3600))
        self.iat = IssuedAtClaim(value: now)
        self.iss = IssuerClaim(value: iss)
        self.sub = SubjectClaim(value: sub)
        self.scope = scope
        self.aud = AudienceClaim(value: aud)
    }

    func verify(using signer: JWTSigner) throws {
        // not used
    }
}
