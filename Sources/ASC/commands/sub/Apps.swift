//
//  Apps.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation
import ASCKit
import ArgumentParser

extension ASC {

    struct Apps: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage your apps in App Store Connect.",
            subcommands: [List.self]
        )
    }
}

extension ASC.Apps {

    /// Find and list apps added in App Store Connect.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_apps
    struct List: AsyncParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Find and list apps added in App Store Connect.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_apps for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?
        
        @Argument(help: "The attribute you want to get. [name | bundleId | locale | attributes] (default: id).")
        var attribute: String?

        func run() async throws {
            let list: [App] = try await ASCService.list(filters: filters, limit: limit)
            list.out(attribute)
        }
    }
}
