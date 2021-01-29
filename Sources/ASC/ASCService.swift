//
//  Network+Requests.swift
//  ASC
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Core

struct ASCService {

    static let network = Network()

    // MARK: - BetaGroups

    static func listBetaGroups(filters: [Filter] = []) throws -> [Group] {

        let resource = AscResource.listBetaGroups(filters: filters)
        let result: RequestResult<[Group]> = try network.syncRequest(resource: resource)
        return try result.get()
    }

    // MARK: - Apps

    static func listApps(filters: [Filter] = []) throws -> [App] {

        let resource = AscResource.listApps(filters: filters)
        let result: RequestResult<[App]> = try network.syncRequest(resource: resource)
        return try result.get()
    }

    static func listAppStoreVersions(appIds: [String], filters: [Filter] = []) throws -> [(app: App, versions: [AppStoreVersion])] {

        let apps = try listApps()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        var functionResult: [(app: App, versions: [AppStoreVersion])] = []
        var errors: [Error] = []

        for id in iterableAppIds {
            let resource = AscResource.listAppStoreVersions(appId: id, filters: filters)
            let result: RequestResult<[AppStoreVersion]> = try network.syncRequest(resource: resource)

            switch result {
            case let .success(versions):
                let app = apps.first(where: { $0.id == id })!
                functionResult.append((app: app, versions: versions))
            case let .failure(error):
                errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }

        return functionResult
    }

    // MARK: - BetaTester

    static func listBetaTester(filters: [Filter] = []) throws -> [BetaTester] {

        let resource = AscResource.listBetaTester(filters: filters)
        let result: RequestResult<[BetaTester]> = try network.syncRequest(resource: resource)
        return try result.get()
    }

    static func inviteBetaTester(email: String, appIds: [String]) throws {

        let apps = try listApps()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        guard iterableAppIds.count > 0 else {
            throw AscError.noDataProvided("app_ids")
        }

        guard let tester = try listBetaTester(filters: [Filter(key: BetaTester.FilterKey.email, value: email)]).first else {
            throw AscError.noUserFound(email)
        }

        var receivedObjects: [BetaTesterInvitationResponse] = []
        var errors: [Error] = []

        for id in iterableAppIds {
            let resource = AscResource.inviteBetaTester(testerId: tester.id, appId: id)
            let result: RequestResult<BetaTesterInvitationResponse> = try network.syncRequest(resource: resource)
            let app = apps.filter { id == $0.id }[0]

            switch result {
            case let .success(result):
                receivedObjects.append(result)
                print("Invited tester \(tester.name)  (\(tester.id)) to app \(app.name) (\(id))")
            case let .failure(error):
                print("Failed inviting tester \(tester.name) (\(tester.id)) to app \(app.name) (\(id))")
                errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }

    static func addBetaTester(email: String, first: String, last: String, groupNames: [String]) throws -> [BetaTester] {

        let betaGroups: Set<Group> = try groupNames
            // create filters for group names
            .map({ Filter(key: Group.FilterKey.name, value: $0) })
            // union of groups of different names
            .reduce([], { $0.union(try listBetaGroups(filters: [$1])) })

        var receivedObjects: [BetaTester] = []
        var errors: [Error] = []

        for id in betaGroups.map(\.id) {
            let resource = AscResource.addBetaTester(email: email, firstName: first, lastName: last, groupId: id)
            let result: RequestResult<BetaTester> = try network.syncRequest(resource: resource)

            switch result {
            case let .success(result):
                receivedObjects.append(result)
                let betaGroup = betaGroups.filter { id == $0.id }[0]
                print("Added tester \(result.name) (\(email)) to group \(String(describing: betaGroup.name)) (\(id))")
            case let .failure(error): errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
        return receivedObjects
    }

    static func deleteBetaTester(emails: String, groupIds: [String]) throws {

        guard emails.count > 0 else { throw AscError.noDataProvided("email") }

        let filter = Filter(key: BetaTester.FilterKey.email, value: emails)
        let foundTesters = try listBetaTester(filters: [filter]) // sync

        guard foundTesters.count > 0 else { return }

        var receivedObjects: [EmptyResponse] = []
        var errors: [Error] = []

        for tester in foundTesters {
            let resource = AscResource.deleteBetaTester(id: tester.id)
            let result: RequestResult<EmptyResponse> = try network.syncRequest(resource: resource)

            switch result {
            case let .success(result):
                receivedObjects.append(result)
                var messages = ["Removed \(tester.name)"]
                if let email = tester.attributes.email { messages.append("(\(email))")}
                print(messages.joined(separator: " "))
            case let .failure(error): errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }
}

extension ASCService: Service {

    func jsonDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try Json.decoder.decode(DataWrapper<T>.self, from: data).object
    }
}
