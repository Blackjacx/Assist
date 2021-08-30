//
//  Snap.swift
//  
//
//  Created by Stefan Herold on 21.09.20.
//

import Foundation
import Engine
import ArgumentParser
import Core

/// The main class for the screen-shotting tool
public final class Snap: ParsableCommand {

    public static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "Make your mobile screenshot automation a breeze and blazingly fast.",

        // Commands can define a version for automatic '--version' support.
        version: "0.0.8",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Run.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Run.self
    )

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
