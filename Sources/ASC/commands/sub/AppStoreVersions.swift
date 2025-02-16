//
//  AppStoreVersions.swift
//  ASC
//
//  Created by Stefan Herold on 07.09.20.
//

import Foundation
import TabularData
import ASCKit
import ArgumentParser

extension ASC {

    struct AppStoreVersions: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage versions of your app that are available in App Store.",
            subcommands: [List.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.AppStoreVersions {

    /// Get a list of all App Store versions of an app across all platforms.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_all_app_store_versions_for_an_app
    struct List: AsyncParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Get a list of all App Store versions of an app across all platforms.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_all_app_store_versions_for_an_app for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "The IDs of the apps you want to get the versions from.")
        var appIds: [String] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        @Argument(help: "The attribute you are interested in. [attributes] (default: id).")
        var attribute: String?

        func run() async throws {
            let result = try await ASCService.listAppStoreVersions(
                appIds: appIds,
                filters: filters,
                limit: limit
            )

            let outModel: [OutModel] = result.map {
                OutModel(
                    // Trimming removed invisible characters in some apps names
                    // and makes the table look smooth.
                    name: $0.app.name.trimmingCharacters(in: .alphanumerics.inverted),
                    version: $0.versions.first?.attributes.versionString,
                    storeState: $0.versions.first?.attributes.appStoreState.rawValue
                )
            }.sorted()
            let data = try JSONEncoder().encode(outModel)

            // Create the DataFrame from .json data
            let dataFrame = try DataFrame(jsonData: data)

            // Beautiful print
            let options = FormattingOptions(
                maximumLineWidth: 1000,
                maximumCellWidth: 200,
                maximumRowCount: 1000000,
                includesColumnTypes: false
            )
            let groupedFrame = dataFrame.grouped(by: "version").counts(order: .ascending)
            print(dataFrame.description(options: options))
            print(groupedFrame.description(options: options))
        }
    }
}

private struct OutModel: Codable, Comparable {
    static func < (lhs: OutModel, rhs: OutModel) -> Bool {
        lhs.name.caseInsensitiveCompare(rhs.name) == .orderedAscending
    }

    var name: String
    var version: String?
    var storeState: String?
}
