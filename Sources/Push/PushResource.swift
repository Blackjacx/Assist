//
//  PushResource.swift
//  Push
//
//  Created by Stefan Herold on 11.08.20.
//

import Foundation
import Core

enum PushResource {
    case pushViaApns(credentials: JSONWebTokenCredentials, endpoint: Push.Apns.Endpoint, deviceToken: String, topic: String, message: String)
}

extension PushResource: Resource {

    static var token: String?
    static let service: Service = PushService()

    var host: String { 
      switch self {
        case let .pushViaApns(_, endpoint, _, _, _): return endpoint.host
      }
    }
    
    var port: Int? { 
      switch self {
        case .pushViaApns: return 443
      }
    }

    var path: String {
        switch self {
        case .pushViaApns(_, _, let deviceToken, _, _): return "/3/device/\(deviceToken)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .pushViaApns: return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .pushViaApns:
            return .post
        }
    }

    var shouldAuthorize: Bool {
        true
    }

    var headers: [String : String]? {

        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        switch self {
        case let .pushViaApns(credentials, _, _, topic, _):
          headers["apns-topic"] = topic
          headers["apns-push-type"] = "alert"

          if shouldAuthorize {
            do {
                let token = try JSONWebToken.token(useCase: .apns, credentials: credentials)
                headers["Authorization"] = "Bearer \(token)"
            } catch {
                print("Error generating token: \(error)")
            }
          }
        }

        return headers
    }

    var parameters: [String : Any]? {
      switch self {
        case let .pushViaApns(_, _, _, _, message):
          return ["aps": ["alert": message]]
        }
    }
}
