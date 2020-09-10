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

        let result: RequestResult<[Group]> = try Self.network.syncRequest(resource: AscResource.listBetaGroups(filters: filters))

        switch result {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    // MARK: - Apps

    static func listApps(filters: [Filter] = []) throws -> [App] {

        let result: RequestResult<[App]> = try Self.network.syncRequest(resource: AscResource.listApps(filters: filters))

        switch result {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    static func listAppStoreVersions(appIds: [String], filters: [Filter] = []) throws -> [(app: App, versions: [AppStoreVersion])] {

        let apps = try listApps()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        var functionResult: [(app: App, versions: [AppStoreVersion])] = []

        let semaphore = DispatchSemaphore(value: 0)
        let scheduledRequests = iterableAppIds.count
        var finishedRequests = 0
        var error: Error?

        for id in iterableAppIds {
            let resource = AscResource.listAppStoreVersions(appId: id, filters: filters)
            try network.request(resource: resource) { (networkResult: RequestResult<[AppStoreVersion]>) in
                switch networkResult {
                case let .success(versions):
                    let app = apps.first(where: { $0.id == id })!
                    functionResult.append((app: app, versions: versions))
                case let .failure(err):
                    error = err
                    semaphore.signal()
                    return
                }
                finishedRequests += 1

                if finishedRequests == scheduledRequests {
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()

        if let error = error {
            throw error
        }
        return functionResult
    }

    // MARK: - BetaTester

    static func listBetaTester(filters: [Filter] = []) throws -> [BetaTester] {

        let result: RequestResult<[BetaTester]> = try Self.network.syncRequest(resource: AscResource.listBetaTester(filters: filters))

        switch result {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    static func addBetaTester(email: String,
                              first: String,
                              last: String,
                              groupIDs: [String]) throws -> [BetaTester] {

        let betaGroups = try listBetaGroups()
        let iterableGroupIds = groupIDs.count > 0 ? groupIDs : betaGroups.map { $0.id }

        guard iterableGroupIds.count > 0 else { throw AscError.noDataProvided("group_ids") }

        var receivedObjects: [BetaTester] = []
        var errors: [Error] = []

        for id in iterableGroupIds {
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

        if errors.count > 0 {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
        return receivedObjects
    }

    static func deleteBetaTester(emails: String, groupIds: [String]) throws {

        guard emails.count > 0 else { throw AscError.noDataProvided("email") }

        let filter = Filter(key: BetaTester.FilterKey.email, value: emails)
        let foundTesters = try listBetaTester(filters: [filter]) // sync

        guard foundTesters.count > 0 else { return }

        let semaphore = DispatchSemaphore(value: 0)
        let scheduledRequests = foundTesters.count
        var receivedObjects: [EmptyResponse] = []
        var errors: [Error] = []

        for tester in foundTesters {
            let resource = AscResource.deleteBetaTester(id: tester.id)
            try network.request(resource: resource) { (networkResult: RequestResult<EmptyResponse>) in
                switch networkResult {
                case let .success(unwrappedResult):
                    receivedObjects.append(unwrappedResult)
                    print("Removed \(tester.name) (\(String(describing: tester.attributes.email)).")
                case let .failure(error): errors.append(error)
                }
                if receivedObjects.count + errors.count == scheduledRequests { semaphore.signal() }
            }
        }
        semaphore.wait()

        if errors.count > 0 {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }
}

extension ASCService: Service {

    func jsonDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try Json.decoder.decode(DataWrapper<T>.self, from: data).object
    }
}
