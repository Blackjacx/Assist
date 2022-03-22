//
//  BundleIds.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation
import ASCKit
import ArgumentParser

extension ASC {

    struct BundleIds: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage the bundle IDs that uniquely identify your apps.",
            subcommands: [List.self, Register.self, Delete.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.BundleIds {

    /// Manage the bundle IDs that uniquely identify your apps.
    /// https://developer.apple.com/documentation/appstoreconnectapi/bundle_ids
    struct List: AsyncParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Find and list bundle IDs that are registered to your team.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/bundle_ids for possible values.")
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        @Argument(help: "The attribute you want to get. [identifier | name | platform | seedId] (default: id).")
        var attribute: String?

        func run() async throws {
            let list: [BundleId] = try await ASCService.list(filters: filters, limit: limit)
            list.out(attribute)
        }
    }

    /// Register a new bundle ID for app development.
    /// https://developer.apple.com/documentation/appstoreconnectapi/register_a_new_bundle_id
    struct Register: AsyncParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Register a new bundle ID for app development.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "The bundleId itself.")
        var identifier: String

        @Option(name: .shortAndLong, help: "Name of the bundle identifier")
        var name: String

        @Option(name: .shortAndLong, help: "Platform the bundleId's app will be for. \(BundleId.Platform.allCases.map { $0.rawValue })")
        var platform: BundleId.Platform = .universal

        @Option(name: .shortAndLong, help: "A custom prefix for the bundleId")
        var seedId: String?

        @Argument(help: "The attribute you want to get. [identifier | name | platform | seedId] (default: id).")
        var attribute: String?

        func run() async throws {
            let bundleId: BundleId = try await ASCService.registerBundleId(identifier, name: name, platform: platform, seedId: seedId)
            [bundleId].out(attribute)
        }
    }

    /// Delete a bundle ID that is used for app development.
    /// https://developer.apple.com/documentation/appstoreconnectapi/delete_a_bundle_id
    struct Delete: AsyncParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Delete a bundle ID that is used for app development.",
                                                        discussion: "You can only delete bundle IDs that are used for development. You can’t delete bundle IDs that are being used by an app in App Store Connect.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: ApiKeyOptions

        @Option(name: .shortAndLong, help: "A list of bundle ids like \"com.company.app_name\".")
        var identifiers: [String]

        func run() async throws {

            var errors: [Error] = []

            for id in identifiers {
                do {
                    let deletedId = try await ASCService.deleteBundleId(id)
                    print("Successfully removed \(deletedId)")
                } catch {
                    errors.append(error)
                }
            }

            if !errors.isEmpty {
                throw AscError.requestFailed(underlyingErrors: errors)
            }
        }
    }
}

extension BundleId.Platform: ExpressibleByArgument {}
