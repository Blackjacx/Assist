//
//  AscResource.swift
//  ASC
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Core

enum AscResource {
    case read(url: URL, filters: [Filter])
    case listApps(filters: [Filter])
    case listAppStoreVersions(appId: String, filters: [Filter])
    case listBetaGroups(filters: [Filter])
    case listBetaTester(filters: [Filter])
    case addBetaTester(email: String, firstName: String, lastName: String, groupId: String)
    case deleteBetaTester(id: String)
}

extension AscResource: Resource {

    static var token: String?
    static let service: Service = ASCService()
    static let apiVersion: String = "v1"
    
    var host: String { "api.appstoreconnect.apple.com" }

    var port: Int? { nil } 

    var path: String {
        switch self {
        case .read(let url, _): return url.path
        case .listApps: return "/\(Self.apiVersion)/apps"
        case .listAppStoreVersions(let appId, _): return "/\(Self.apiVersion)/apps/\(appId)/appStoreVersions"
        case .listBetaGroups: return "/\(Self.apiVersion)/betaGroups"
        case .listBetaTester: return "/\(Self.apiVersion)/betaTesters"
        case .addBetaTester: return "/\(Self.apiVersion)/betaTesters"
        case .deleteBetaTester(let id): return "/\(Self.apiVersion)/betaTesters/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .read(_, let filters): return queryItems(from: filters)
        case .listApps(let filters): return queryItems(from: filters)
        case .listAppStoreVersions(_, let filters): return queryItems(from: filters)
        case .listBetaGroups(let filters): return queryItems(from: filters)
        case .listBetaTester(let filters): return queryItems(from: filters)
        default: return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .read, .listBetaGroups, .listApps, .listAppStoreVersions, .listBetaTester:
            return .get
        case .addBetaTester:
            return .post
        case .deleteBetaTester:
            return .delete
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
                let token = try JSONWebToken.tokenAsc()
                headers["Authorization"] = "Bearer \(token)"
            } catch {
                print(error)
            }
        }
        return headers
    }

    var parameters: [String : Any]? {
        switch self {
        case .read, .listBetaGroups, .listApps, .listAppStoreVersions, .listBetaTester, .deleteBetaTester:
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

extension AscResource {

    private func queryItems(from filters: [Filter]) -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: "limit", value: "200")]
        items += filters.map { URLQueryItem(name: "filter[\($0.key)]", value: $0.value) }
        return items
    }
}
