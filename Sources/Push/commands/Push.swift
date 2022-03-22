//
//  Push.swift
//  Push
//
//  Created by Stefan Herold on 11.08.20.
//

import Foundation
import Engine
import ArgumentParser
import Core

/// The main class for the Push command line tool.
@main
public final class Push: AsyncParsableCommand {

    public static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for sending and testing push notifications to Apple Push Notification Service (APNS) and via Firebase.",

        // Commands can define a version for automatic '--version' support.
        version: "0.0.8",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Apns.self, Fcm.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Apns.self)

    public init() {}
}

/// Here you can specify parameters valid for all sub commands.
struct Options: ParsableArguments {

    @Flag(name: .shortAndLong, help: "Activate verbose logging.")
    var verbose: Int

    @Option(name: .shortAndLong, help: "The token of the device you want to push to.")
    var deviceToken: String

    @Option(name: .shortAndLong, help: "The message you want to send.")
    var message: String

    mutating func validate() throws {
        // Misusing validate to set the received flag globally
        Network.verbosityLevel = verbose
    }
}

