//
//  AppStoreVersions.swift
//  ASC
//
//  Created by Stefan Herold on 07.09.20.
//

import Foundation
import ASCKit
import ArgumentParser

extension ASC {

    struct AppStoreVersions: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage versions of your app that are available in App Store.",
            subcommands: [List.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.AppStoreVersions {

    /// Get a list of all App Store versions of an app across all platforms.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_all_app_store_versions_for_an_app
    struct List: ParsableCommand {
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

        func run() throws {
            let result = try ASCService.listAppStoreVersions(appIds: appIds, filters: filters, limit: limit)
            for item in result {
                if let readyForSaleVersion = item.versions.filter({ $0.attributes.appStoreState == .readyForSale }).first {
                    print("\(item.app.name.padding(toLength: 30, withPad: " ", startingAt: 0)): \(readyForSaleVersion.attributes.versionString)")
                } else {
                    print("\(item.app.name.padding(toLength: 30, withPad: " ", startingAt: 0)): NOT FOR SALE")
                }
            }
            //            result.flatMap{ $0.versions }.out(attribute)
        }
    }
}
