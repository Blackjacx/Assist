//
//  BetaTesters.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation
import ASCKit
import ArgumentParser

extension ASC {

    struct BetaTesters: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage people who can install and test prerelease builds.",
            subcommands: [List.self, Invite.self, Add.self, Delete.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.BetaTesters {

    /// Find and list beta testers for all apps, builds, and beta groups.
    /// https://developer.apple.com/documentation/appstoreconnectapi/list_beta_testers
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Find and list beta testers for all apps, builds, and beta groups.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/list_beta_testers for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?
        
        @Argument(help: "The attribute you are interested in. [firstName | lastName | email | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            let list: [BetaTester] = try ASCService.list(filters: filters, limit: limit)
            list.out(attribute)
        }
    }

    /// Send or resend an invitation to a beta tester to test a specified app.
    /// https://developer.apple.com/documentation/appstoreconnectapi/send_an_invitation_to_a_beta_tester
    struct Invite: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Send or resend an invitation to a beta tester to test specified apps.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: [.customShort("i", allowingJoined: false), .long], parsing: .upToNextOption, help: "The Apple app ID(s) that uniquely identifiy the app(s) (e.g. -i \"12345678\" -i \"14324567\").")
        var appIds: [String] = []

        @Option(name: .shortAndLong, help: "The unique email of the tester to send the invite to.")
        var email: String

        func run() throws {
            try ASCService.inviteBetaTester(email: email, appIds: appIds)
        }
    }

    /// Create a beta tester assigned to a group, a build, or an app.
    /// https://developer.apple.com/documentation/appstoreconnectapi/create_a_beta_tester
    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Create a beta tester assigned to a group, a build, or an app.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: [.long, .customShort("n")], help: "The first name of the user.")
        var firstName: String

        @Option(name: .shortAndLong, help: "The last name of the user.")
        var lastName: String

        @Option(name: .shortAndLong, help: "The email of the user.")
        var email: String

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "The group names to add the new beta tester to.")
        var groupNames: [String]

        func run() throws {
            try ASCService.addBetaTester(email: email, first: firstName, last: lastName, groupNames: groupNames)
        }
    }

    /// Remove a beta tester's ability to test all or specific apps.
    /// https://developer.apple.com/documentation/appstoreconnectapi/delete_a_beta_tester
    struct Delete: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Remove a beta tester's ability to test all or specific apps.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions
        
        @Option(name: .shortAndLong, help: "A list of emails of users you want to remove.")
        var emails: [String]

        func run() throws {
            // Get id's
            let filter = Filter(key: BetaTester.FilterKey.email, value: emails.joined(separator: ","))
            let list: [BetaTester] = try ASCService.list(filters: [filter], limit: nil)

            // Delete items by id
            let ops = list.map { DeleteOperation<BetaTester>(model: $0) }
            ops.executeSync()
            try ops.forEach { _ = try $0.result.get() } // logs error
        }
    }
}
