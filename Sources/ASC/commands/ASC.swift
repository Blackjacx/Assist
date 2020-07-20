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

