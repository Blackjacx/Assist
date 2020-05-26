//
//  AscResource.swift
//  ASC
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Core

enum AscResource {
    case readBetaGroups
}

extension AscResource: Resource {

    static var token: String?

    var baseURL: URL {
        URL(string: "https://api.appstoreconnect.apple.com/v1")!
    }

    var path: String {
        switch self {
        case .readBetaGroups: return "betaGroups"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .readBetaGroups: return .get
        }
    }

    var shouldAuthorize: Bool {
        true
    }

    var headers: [String : String]? {

        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        if let token = Self.token, shouldAuthorize {
            headers["Authorization"] = token
        }

        return headers
    }
}
