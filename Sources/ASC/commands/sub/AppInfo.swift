//
//  AppInfos.swift
//  ASC
//
//  Created by Stefan Herold on 23.10.25.
//

import ArgumentParser
import ASCKit
import Foundation

extension ASC {

    /// Manage or read the app metadata that applies across all versions of your app.
    /// https://developer.apple.com/documentation/appstoreconnectapi/app-infos
    struct AppInfo: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage or read the app metadata that applies across all versions of your app.",
            subcommands: [
                List.self,
            ]
        )
    }
}

extension ASC.AppInfo {

    /// Get information about an app that is currently live on App Store, or that goes live with the next version.
    struct List: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get information about an app that is currently live on App Store, or that goes live with the next version."
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the app resource ID from the List Apps response."
        )
        var appId: String

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        func run() async throws {
            try await ASCService.listAppInfos(
                appId: appId,
                limit: limit,
                outputType: options.outputType,
            )
        }
    }
}
