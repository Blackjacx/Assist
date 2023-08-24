//
//  PushEndpoint.swift
//  Push
//
//  Created by Stefan Herold on 11.08.20.
//

import Foundation
import Engine
import Core

enum PushEndpoint {
    case pushViaApns(credentials: JWTApnsCredentials, endpoint: Push.Apns.Endpoint, deviceToken: String, topic: String, message: String)
    case pushViaFcm(deviceToken: String, message: String, credentials: JWTFcmCredentials)
}

extension PushEndpoint: Endpoint {

    static var token: String?

    var url: URL? { nil }
    
    var host: String { 
      switch self {
        case .pushViaApns(_, let endpoint, _, _, _): return endpoint.host
        case .pushViaFcm: return "fcm.googleapis.com"
      }
    }
    
    var port: Int? { 
      switch self {
        case .pushViaApns: return 443
        case .pushViaFcm: return nil
      }
    }

    var path: String {
        switch self {
        case let .pushViaApns(_, _, deviceToken, _, _): return "/3/device/\(deviceToken)"
        case let .pushViaFcm(_, _, credentials): return "/v1/projects/\(credentials.projectId)/messages:send"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .pushViaApns: return []
        case .pushViaFcm: return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .pushViaApns, .pushViaFcm:
            return .post
        }
    }

    var timeout: TimeInterval {
        30
    }
    
    var shouldAuthorize: Bool {
        true
    }

    func headers() async -> [String : String]? {

        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        guard shouldAuthorize else {
          return headers
        }

        switch self {
        case let .pushViaApns(credentials, _, _, topic, _):
          headers["apns-topic"] = topic
          headers["apns-push-type"] = "alert"

          do {
              let token = try await JSONWebToken.token(for: .apns(credentials: credentials))
              headers["Authorization"] = "Bearer \(token)"
          } catch {
              print("Error generating token: \(error)")
          }

        case let .pushViaFcm(_, _, credentials):
          do {
              let token = try await JSONWebToken.token(for: .fcm(credentials: credentials))
              headers["Authorization"] = "Bearer \(token)"
          } catch {
              print("Error generating token: \(error)")
          }
        }

        return headers
    }

    var parameters: [String : Any]? {
      switch self {
        case let .pushViaApns(_, _, _, _, message):
          return ["aps": ["alert": message]]
        case let .pushViaFcm(deviceToken, message, _):
          return ["message": ["notification": ["title": "Hello FCM", "body": message], "token": deviceToken]]
        }
    }

    func jsonDecode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let dataResult = Result {
            try Json.decoder.decode(DataWrapper<T>.self, from: data)
        }.map {
            $0.data
        }

        guard (try? dataResult.get()) != nil else {
            // Decode model directly
            return try Json.decoder.decode(T.self, from: data)
        }

        // Extract data wrapped model OR throw the error from decoding it
        return try dataResult.get()
    }
}
