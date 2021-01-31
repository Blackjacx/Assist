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

    static let network = Network()

   
    // MARK: - APNS

    @discardableResult
    static func pushViaApns(credentials: JWTApnsCredentials,
                            endpoint: Push.Apns.Endpoint, 
                            deviceToken: String, 
                            topic: String, 
                            message: String) throws -> EmptyResponse {

        let result: RequestResult<EmptyResponse> = 
            Self.network.syncRequest(resource: PushResource.pushViaApns(credentials: credentials,
                                                                        endpoint: endpoint,
                                                                        deviceToken: deviceToken,
                                                                        topic: topic,
                                                                        message: message))
        switch result {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    // MARK: - FCM

    @discardableResult
    static func pushViaFcm(deviceToken: String,
                           message: String, 
                           serviceAccountJsonPath: String) throws -> EmptyResponse {

        guard let data = FileManager.default.contents(atPath: serviceAccountJsonPath) else {
          throw JSONWebToken.Error.googleServiceAccountJsonNotFound(path: serviceAccountJsonPath)
        }
        let credentials = try Json.decoder.decode(JWTFcmCredentials.self, from: data)
        let result: RequestResult<EmptyResponse> = 
            Self.network.syncRequest(resource: PushResource.pushViaFcm(deviceToken: deviceToken,
                                                                       message: message,
                                                                       credentials: credentials))
        switch result {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }
}

extension PushService: Service {

    func jsonDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {

        let dataResult = Result {
            try Json.decoder.decode(DataWrapper<T>.self, from: data)
        }.map {
            $0.object
        }

        guard (try? dataResult.get()) != nil else {
            // Decode model directly
            return try Json.decoder.decode(T.self, from: data)
        }

        // Extract data wrapped model OR throw the error from decoding it
        return try dataResult.get()
    }
}
