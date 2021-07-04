//
//  Keys.swift
//  ASC
//
//  Created by Stefan Herold on 17.11.20.
//

import Foundation
import ASCKit
import Engine
import ArgumentParser

extension ASC {

    /// Lists, registers and deletes App Store Connect API keys locally.
    struct Keys: ParsableCommand {

        static var configuration = CommandConfiguration(
            abstract: "Lists, registers and deletes App Store Connect API keys on your Mac.",
            subcommands: [List.self, Activate.self, Register.self, Delete.self],
            defaultSubcommand: List.self)
    }
}

extension ASC.Keys {

    /// List locally stored App Store Connect API keys.
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "List locally stored App Store Connect API keys.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        func run() throws {
            ASCService.listApiKeys().forEach { print($0) }
        }
    }

    /// List locally stored App Store Connect API keys.
    struct Activate: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Makes a registered API key the default one.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The key's id.")
        var id: String

        func run() throws {
            let activatedKey = try ASCService.activateApiKey(id: id)
            print(activatedKey)
        }
    }

    /// Registers App Store Connect API keys locally.
    struct Register: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Registers App Store Connect API keys locally.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The key's id.")
        var id: String

        @Option(name: .shortAndLong, help: "The key's name you. You can choose freely.")
        var name: String

        @Option(name: .shortAndLong, help: "The absolute path to the p8 key file.")
        var path: String

        @Option(name: [.long, .customShort("s")], help: "The id of the key issuer.")
        var issuerId: String

        func run() throws {
            let key = ApiKey(id: id, name: name, source: .localFilePath(path: path), issuerId: issuerId)
            let registeredKey = try ASCService.registerApiKey(key: key)
            print(registeredKey)
        }
    }

    /// Delete locally stored App Store Connect API keys.
    struct Delete: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Delete locally stored App Store Connect API keys.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The key's id.")
        var id: String

        func run() throws {
            let deletedKey = try ASCService.deleteApiKey(id: id)
            print(deletedKey)
        }
    }
}
