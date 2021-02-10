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
            subcommands: [List.self],
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
        var options: Options

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_builds for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        @Argument(help: "The attribute you want to get [expired, minOsVersion, processingState, version, usesNonExemptEncryption, uploadedDate, expirationDate] (default: id).")
        var attribute: String?

        func run() throws {
            let op = ListOperation<Build>(filters: filters, limit: limit)
            op.executeSync()
            try op.result.get().out(attribute)
        }
    }
}
