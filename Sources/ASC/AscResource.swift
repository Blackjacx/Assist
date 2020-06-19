//
//  AscResource.swift
//  ASC
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Core

enum AscResource {
    case read(url: URL)
    case readApps
    case readBetaGroups
}

extension AscResource: Resource {

    static var token: String?
    static let service: Service = ASCService()
    static let apiVersion: String = "v1"

    var baseURL: URL {
        URL(string: "https://api.appstoreconnect.apple.com")!
    }

    var path: String {
        switch self {
        case .read(let url): return url.path
        case .readApps: return "\(Self.apiVersion)/apps"
        case .readBetaGroups: return "\(Self.apiVersion)/betaGroups"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .read, .readBetaGroups, .readApps:
            return .get
        }
    }

    var shouldAuthorize: Bool {
        true
    }

    var headers: [String : String]? {

        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        if let token = JWT.token, shouldAuthorize {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }
}
