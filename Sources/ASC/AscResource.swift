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
    case listAppStoreVersions(appId: String, filters: [Filter])
    case readBetaGroups
    case listBetaTester(email: String?, firstName: String?, lastName: String?)
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
        case .read(let url): return url.path
        case .readApps: return "/\(Self.apiVersion)/apps"
        case .listAppStoreVersions(let appId, _): return "/\(Self.apiVersion)/apps/\(appId)/appStoreVersions"
        case .readBetaGroups: return "/\(Self.apiVersion)/betaGroups"
        case .listBetaTester: return "/\(Self.apiVersion)/betaTesters"
        case .addBetaTester: return "/\(Self.apiVersion)/betaTesters"
        case .deleteBetaTester(let id): return "/\(Self.apiVersion)/betaTesters/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        switch self {
        case .listAppStoreVersions(_, let filters):
            queryItems = filters.map { URLQueryItem(name: "filter[\($0.key)]", value: $0.value) }
        case .listBetaTester(let email, let firstName, let lastName):
            if let email = email { queryItems.append(URLQueryItem(name: "filter[email]", value: email)) }
            if let firstName = firstName { queryItems.append(URLQueryItem(name: "filter[firstName]", value: firstName)) }
            if let lastName = lastName { queryItems.append(URLQueryItem(name: "filter[lastName]", value: lastName)) }
        default: break
        }
        return queryItems
    }

    var method: HTTPMethod {
        switch self {
        case .read, .readBetaGroups, .readApps, .listAppStoreVersions, .listBetaTester:
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
        case .read, .readBetaGroups, .readApps, .listAppStoreVersions, .listBetaTester, .deleteBetaTester:
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
