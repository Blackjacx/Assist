//
//  RegisterApiKey.swift
//  ASC
//
//  Created by Stefan Herold on 17.11.20.
//

import Foundation
import ArgumentParser
import Core

extension ASC {

    /// Lists, registers and deletes App Store Connect API keys locally.
    struct ApiKeys: ParsableCommand {

        static var configuration = CommandConfiguration(
            abstract: "Lists, registers and deletes App Store Connect API keys on your Mac.",
            subcommands: [List.self, Register.self, Delete.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.ApiKeys {

    /// List locally stored App Store Connect API keys.
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "List locally stored App Store Connect API keys keys.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        func run() throws {
            let op = ApiKeysOperation(.list)
            op.executeSync()
            try op.result.get().forEach { print($0) }
        }
    }

    /// Registers App Store Connect API keys locally.
    struct Register: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Registers App Store Connect API keys locally.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The name of the key.")
        var name: String

        @Option(name: .shortAndLong, help: "The absolute path to the p8 key file.")
        var path: String

        @Option(name: .shortAndLong, help: "Key key's id.")
        var keyId: String

        @Option(name: .shortAndLong, help: "The id of the key issuer.")
        var issuerId: String

        func run() throws {
            let key = ApiKey(name: name, path: path, keyId: keyId, issuerId: issuerId)
            let ops = [
                ApiKeysOperation(.register(key: key)),
                ApiKeysOperation(.list)
            ]
            (ops as [Command]).executeSync()
        }
    }

    /// Delete locally stored App Store Connect API keys.
    struct Delete: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Delete locally stored App Store Connect API keys.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "Key key's id.")
        var keyId: String

        func run() throws {
            let ops = [
                ApiKeysOperation(.delete(keyId: keyId)),
                ApiKeysOperation(.list)
            ]
            (ops as [Command]).executeSync()
        }
    }
}
