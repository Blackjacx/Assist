//
//  PushService.swift
//  Push
//
//  Created by Stefan Herold on 11.08.20.
//

import Foundation
import Engine
import Core

struct PushService {

    // MARK: - APNS

    @discardableResult
    static func pushViaApns(credentials: JWTApnsCredentials,
                            endpoint: Push.Apns.Endpoint, 
                            deviceToken: String, 
                            topic: String, 
                            message: String) async throws -> EmptyResponse {

        let endpoint = PushEndpoint.pushViaApns(credentials: credentials,
                                                endpoint: endpoint,
                                                deviceToken: deviceToken,
                                                topic: topic,
                                                message: message)
        return try await Network.shared.request(endpoint: endpoint)
    }

    // MARK: - FCM

    @discardableResult
    static func pushViaFcm(deviceToken: String,
                           message: String, 
                           serviceAccountJsonPath: String) async throws -> EmptyResponse {

        guard let data = FileManager.default.contents(atPath: serviceAccountJsonPath) else {
            throw JWT.Error.googleServiceAccountJsonNotFound(path: serviceAccountJsonPath)
        }

        let credentials = try Json.decoder.decode(JWTFcmCredentials.self, from: data)
        let endpoint = PushEndpoint.pushViaFcm(deviceToken: deviceToken, message: message, credentials: credentials)
        return try await Network.shared.request(endpoint: endpoint)
    }
}
