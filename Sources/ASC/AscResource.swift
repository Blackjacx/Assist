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
    case addBetaTester(email: String, firstName: String, lastName: String, groupId: String)
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
        case .addBetaTester: return "\(Self.apiVersion)/betaTesters"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .read, .readBetaGroups, .readApps:
            return .get
        case .addBetaTester:
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

        if shouldAuthorize {
            do {
                let token = try JSONWebToken.token()
                headers["Authorization"] = "Bearer \(token)"
            } catch {
                print(error)
            }
        }
        return headers
    }

    var parameters: [String : Any]? {
        switch self {
        case .read, .readBetaGroups, .readApps:
            return nil
        case let .addBetaTester(email, firstName, lastName, groupId):
            return [
                "data": [
                    "type": "betaTesters",
                    "attributes": [
                        "email": email,
                        "firstName": firstName,
                        "lastName": lastName,
                    ],
                    "relationships": [
                        "betaGroups": [
                            "data": [
                                [ "type": "betaGroups", "id": groupId ]
                            ]
                        ]
                    ]
                ]
            ]
        }
    }
}
