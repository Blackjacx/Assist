import Engine
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum JSONWebToken {
    static let jwt = JWT()

    public enum Service {
        case apns(credentials: JWTApnsCredentials)
        case fcm(credentials: JWTFcmCredentials)
    }

    public static func token(for service: Service) async throws -> String {
        switch service {
        case .apns(let credentials): try await token(credentials: credentials)
        case .fcm(let credentials): try await token(credentials: credentials)
        }
    }

    private static func token(credentials: JWTApnsCredentials) async throws -> String {
        try await jwt.create(
            keySource: .localFilePath(path: credentials.keyPath),
            header: JWTHeaderApns(kid: credentials.keyId),
            payload: JWTPayloadClaimApns(iss: credentials.issuerId)
        )
    }

    /// https://github.com/googleapis/google-auth-library-swift/blob/f3c652646735e27885e81e710d4147f33eb6c26f/Sources/OAuth2/ServiceAccountTokenProvider/ServiceAccountTokenProvider.swift
    /// https://medium.com/rocket-fuel/getting-started-with-firebase-for-server-side-swift-93c11098702a
    /// https://stackoverflow.com/questions/46396224/how-do-i-generate-an-auth-token-using-jwt-for-google-firebase
    private static func token(credentials: JWTFcmCredentials) async throws -> String {
        let jwt = try await jwt.create(
            keySource: .inline(privateKey: credentials.privateKey),
            header: JWTHeaderFcm(),
            payload: JWTPayloadClaimFcm(
                aud: credentials.tokenUrl,
                iss: credentials.clientEmail,
                scope: "https://www.googleapis.com/auth/firebase.messaging",
                sub: credentials.clientEmail
            )
        )

        //
        // With the signed JWT we have to make another request to Google which gives us the token we use to send the
        // push message.
        //

        let jsonData = try JSONSerialization.data(withJSONObject: [
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": jwt
        ])

        var urlRequest = URLRequest(url: URL(string: credentials.tokenUrl)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession(configuration: .default)
        let (data, response) = try await session.data(for: urlRequest, delegate: nil)

        guard let httpResponse = response as? HTTPURLResponse, (200...399).contains(httpResponse.statusCode) else {
            throw JWT.Error.invalidResonse(response: response)
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

private struct JWTHeaderApns: JWTHeader {
    let alg: String? = "ES256"
    let typ: String = "JWT"
    let kid: String
}

private struct JWTPayloadClaimApns: JWTClaims {
    let aud: String? = nil
    let iat: Date = Date()
    let exp: Date? = nil
    let iss: String
    let sub: String? = nil
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

private struct JWTHeaderFcm: JWTHeader {
    let alg: String? = nil
    let typ: String = "JWT"
}

private struct JWTPayloadClaimFcm: JWTClaims {
    let aud: String?
    let iat: Date = Date()
    let exp: Date? = Date().addingTimeInterval(60 * 60)
    let iss: String
    let scope: String
    let sub: String?
}
