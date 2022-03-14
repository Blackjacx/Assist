//
//  Builds.swift
//  ASC
//
//  Created by Stefan Herold on 04.02.20.
//

import Foundation
import ASCKit
import ArgumentParser

extension ASC {

    struct Builds: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage builds for testers and submit builds for review.",
            subcommands: [List.self, Expire.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.Builds {

    /// Find and list builds for all apps in App Store Connect.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_builds
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Find and list builds for all apps in App Store Connect.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_builds for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        @Argument(help: "The attribute you want to get [expired, minOsVersion, processingState, version, usesNonExemptEncryption, uploadedDate, expirationDate] (default: id).")
        var attribute: String?

        func run() async throws {
            let list: [Build] = try await ASCService.list(filters: filters, limit: limit)
            list.out(attribute)
        }
    }

    /// Expire a build.
    /// https://developer.apple.com/documentation/appstoreconnectapi/modify_a_build
    struct Expire: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Expire a build.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Ids if the builds you with to expire.")
        var ids: [String] = []

        @Argument(help: "The attribute you want to get [expired, minOsVersion, processingState, version, usesNonExemptEncryption, uploadedDate, expirationDate] (default: id).")
        var attribute: String?

        func run() async throws {
            let expiredBuilds: [Build] = try await ASCService.expireBuilds(ids: ids)
            expiredBuilds.out(attribute)
        }
    }
}
