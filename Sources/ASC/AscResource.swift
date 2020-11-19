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
    case inviteBetaTester(testerId: String, appId: String)
    case addBetaTester(email: String, firstName: String, lastName: String, groupId: String)
    case deleteBetaTester(id: String)
}

extension AscResource: Resource {

    static let service: Service = ASCService()

    private static let apiVersion: String = "v1"
    private static var apiKey: ApiKey?
    private static func determineToken() throws -> String {

        if apiKey == nil {
            let op = ApiKeysOperation(.list)
            ASC.queue.addOperations([op], waitUntilFinished: true)
            let apiKeys = try op.result.get()

            switch apiKeys.count {
            case 0: throw AscError.noApiKeysSpecified
            case 1: apiKey = apiKeys[0]
            default:
                print("Please choose one of the registered API keys:")
                apiKeys.enumerated().forEach { print("\t \($0). \($1.name) (\($1.keyId))") }

                guard let input = readLine(), let index = Int(input), (0..<apiKeys.count).contains(index) else {
                    throw AscError.invalidInput("Please enter the specified number of the key.")
                }
                apiKey = apiKeys[index]
            }
        }
        return try JSONWebToken.tokenAsc(keyFile: apiKey!.path, kid: apiKey!.keyId, iss: apiKey!.issuerId)
    }

    var host: String { "api.appstoreconnect.apple.com" }

    var port: Int? { nil } 

    var path: String {
        switch self {
        case .read(let url, _): return url.path
        case .listApps: return "/\(Self.apiVersion)/apps"
        case .listAppStoreVersions(let appId, _): return "/\(Self.apiVersion)/apps/\(appId)/appStoreVersions"
        case .listBetaGroups: return "/\(Self.apiVersion)/betaGroups"
        case .listBetaTester: return "/\(Self.apiVersion)/betaTesters"
        case .inviteBetaTester: return "/\(Self.apiVersion)/betaTesterInvitations"
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
        case .addBetaTester, .inviteBetaTester:
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
                let token = try Self.determineToken()
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
        case let .inviteBetaTester(testerId, appId):
            return [
                "data": [
                    "type": "betaTesterInvitations",
                    "relationships": [
                        "app": [
                            "data": [
                                "type": "apps",
                                "id": appId,
                            ]
                        ],
                        "betaTester": [
                            "data": [
                                "type": "betaTesters",
                                "id": testerId,
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
