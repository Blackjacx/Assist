//
//  Groups.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation
import ArgumentParser

extension ASC {

    struct Groups: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage groups of beta testers that have access to one or more builds.",
            subcommands: [List.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.Groups {

    /// Find and list beta groups for all apps.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_beta_groups
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Find and list beta testers for all apps, builds, and beta groups.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_beta_groups for possible values.")
        var filters: [Filter] = []

        @Argument(help: "The attribute you are interested in. [firstName | lastName | email | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            let groups = try ASCService.listBetaGroups(filters: filters)
            groups.out(attribute)
        }
    }
}
