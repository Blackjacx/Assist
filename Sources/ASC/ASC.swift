//
//  ASC.swift
//  ASC
//
//  Created by Stefan Herold on 24.05.20.
//

import Foundation
import ArgumentParser
import Core

/// The main class for this for the App Store Connect command line tool.
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
        subcommands: [Groups.self, Apps.self, BetaTesters.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Groups.self)

    public init() {}
}

/// Here you can specify parameters valid for all sub commands.
struct Options: ParsableArguments {

    // Deprecated - token is specified using environment variables - see JWT.swift
//    static var token: String?
//
//    @Option(name: .shortAndLong, help: "The ASC authorization token.", transform: { (string) in
//        AscResource.token = string
//        return string
//    })
//    var token: String?
}

extension ASC {

    struct Apps: ParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Access ASC apps.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Argument(help: "The attribute you want to get. [name | bundleId | locale | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            let apps = try ASCService.readApps()
            apps.out(attribute)
        }
    }

    struct Groups: ParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Access ASC beta groups.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The name of the group to use. If nil, all groups found are used.")
        var groupName: String?

        @Argument(help: "The attribute you are interested in. [name | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            let groups = try ASCService.readBetaGroups()
            groups.out(attribute, groupName: groupName)
        }
    }

    struct BetaTesters: ParsableCommand {

        static var configuration = CommandConfiguration(
                 abstract: "Manage people who can install and test prerelease builds.",
                 subcommands: [Add.self],
                 defaultSubcommand: Add.self)
    }
}

extension ASC.BetaTesters {

    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Adds a new beta tester.")

        @Option(name: .shortAndLong, help: "The first name of the user.")
        var firstName: String

        @Option(name: .shortAndLong, help: "The last name of the user.")
        var lastName: String

        @Option(name: .shortAndLong, help: "The email of the user.")
        var email: String

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "The groups to add the new beta tester to.")
        var groupIds: [String]

        @Argument(help: "The attribute you are interested in. [firstName | lastName | email | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            for group in groupIds {
                let result = try ASCService.addBetaTester(email: email,
                                                          firstName: firstName,
                                                          lastName: lastName,
                                                          groupId: group)
                result.out(attribute)
            }
        }
    }
}
