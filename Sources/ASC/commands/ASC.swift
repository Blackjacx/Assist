//
//  ASC.swift
//  ASC
//
//  Created by Stefan Herold on 24.05.20.
//

import Foundation
import ASCKit
import Engine
import ArgumentParser
import Core

/// The main class for the App Store Connect command line tool.
@main
public final class ASC: AsyncParsableCommand {

    /// The API key chosen by the user. If only one key is registered this one is automatically used.
    static var apiKey: ApiKey?

    public static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for accessing the App Store Connect API.",

        // Commands can define a version for automatic '--version' support.
        version: Constants.version,

        subcommands: [Keys.self,
                      BetaGroups.self,
                      AccessibilityDeclarations.self,
                      Apps.self,
                      AppStoreVersions.self,
                      BetaTesters.self,
                      Builds.self,
                      BundleIds.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: BetaGroups.self)

    public init() {}
}

/// Here you can specify parameters valid for all sub commands.
struct Options: ParsableArguments {

    @Flag(name: .shortAndLong, help: "Activate verbose logging.")
    var verbose: Int

    mutating func validate() throws {
        // Misusing validate to set the received flag globally
        Network.verbosityLevel = verbose
    }
}

/// Here you can specify parameters valid for all sub commands. Only this one
/// includes the API key since specifying this key is not suitable for every
/// command, e.g. the Keys command itself.
struct ApiKeyOptions: ParsableArguments {

    @Flag(name: .shortAndLong, help: "Activate verbose logging.")
    var verbose: Int

    @Option(name: .shortAndLong, help: "The ID of the key to use.")
    var keyId: String?

    @Option(name: .shortAndLong, help: "The ID of the key to use.")
    var outputType: OutputType = .raw

    mutating func validate() throws {
        // Making desired verbosity level visible to the network layer.
        Network.verbosityLevel = verbose

        // Set the api key ID passed as parameter
        ASCService.specifiedKeyId = keyId
    }
}

extension OutputType: ExpressibleByArgument { }
