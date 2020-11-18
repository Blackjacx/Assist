//
//  ASC.swift
//  ASC
//
//  Created by Stefan Herold on 24.05.20.
//

import Foundation
import ArgumentParser
import Core

/// The main class for the App Store Connect command line tool.
public final class ASC: ParsableCommand {

    /// Concurrent operation queue
    public static let queue = OperationQueue()

    public static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for accessing the App Store Connect API.",

        // Commands can define a version for automatic '--version' support.
        version: "0.0.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [ApiKeys.self, Groups.self, Apps.self, AppStoreVersions.self, BetaTesters.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Groups.self)

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

