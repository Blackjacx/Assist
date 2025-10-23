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

    struct Builds: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage builds for testers and submit builds for review.",
            subcommands: [List.self, Expire.self],
        )
    }
}

extension ASC.Builds {

    /// Find and list builds for all apps in App Store Connect.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_builds
    struct List: AsyncParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Find and list builds for all apps in App Store Connect.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_builds for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        func run() async throws {
            let _: [Build] = try await ASCService.list(
                filters: filters,
                limit: limit,
                outputType: options.outputType,
            )
        }
    }

    /// Expire a build.
    /// https://developer.apple.com/documentation/appstoreconnectapi/modify_a_build
    struct Expire: AsyncParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Expire a build.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Ids if the builds you with to expire.")
        var ids: [String] = []

        func run() async throws {
            let _: [Build] = try await ASCService.expireBuilds(
                ids: ids,
                outputType: options.outputType,
            )
        }
    }
}
