//
//  ASC.swift
//  ASC
//
//  Created by Stefan Herold on 24.05.20.
//

import Foundation
import ArgumentParser
import Core

public final class ASC: ParsableCommand {

    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    public static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for accessing the App Store Connect API.",

        // Commands can define a version for automatic '--version' support.
        version: "0.0.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Groups.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Groups.self)

    public init() {}
}

struct Options: ParsableArguments {

    static var token: String?

    @Option(name: .shortAndLong, help: "The ASC authorization token.", transform: { (string) in
        AscResource.token = string
        return string
    })
    var token: String
}

extension ASC {

    struct Groups: ParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Access ASC beta groups.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The name of the group to use. If nil, all groups found are used.")
        var group: String?

        static let network = Network()

        func run() throws {

            let result: RequestResult<[Group]> = Self.network.syncRequest(resource: AscResource.readBetaGroups)

            switch result {
            case let .success(groups):
                let filteredGroups: [Group]
                if let group = group {
                    filteredGroups = groups.filter { $0.attributes.name == group }
                } else {
                    filteredGroups = groups
                }
                let ids = filteredGroups.map { $0.id }.joined(separator: " ")
                print(ids)

            case let .failure(error):
                print(error)
            }
        }
    }
}
