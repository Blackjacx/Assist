//
//  AgeRatingDeclaration.swift
//  ASC
//
//  Created by Stefan Herold on 23.10.25.
//

import ArgumentParser
import ASCKit
import Foundation

extension ASC {

    /// Read and update age ratings and declarations for your app.
    /// https://developer.apple.com/documentation/appstoreconnectapi/age-ratings
    struct AgeRatingDeclarations: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Read and update age ratings and declarations for your app.",
            subcommands: [
                Get.self,
                Update.self,
            ]
        )
    }
}

extension ASC.AgeRatingDeclarations {
    /// Get the age rating declaration for the app info.
    struct Get: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get the age rating declaration for an app info ID or list all for app ID.",
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Argument(help: "An ID that uniquely identifies either an app or an app info resource.")
        var id: TypedId

        func run() async throws {
            switch id {
            case .appId(let id):
                try await ASCService.listAgeRatingDeclarations(
                    appId: id,
                    outputType: options.outputType
                )
            case .appInfoId(let id):
                try await ASCService.getAgeRatingDeclaration(
                    appInfoId: id,
                    outputType: options.outputType
                )
            }
        }
    }

    /// Provide age-related information so the App Store can determine the age rating for your app.
    struct Update: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Provide age-related information so the App Store can determine the age rating for your app.",
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An ID that uniquely identifies an app resource."
        )
        var appId: String

        @Option(
            name: .shortAndLong,
            help: "All parameters in a single JSON hash. See https://developer.apple.com/documentation/appstoreconnectapi/ageratingdeclarationupdaterequest/data-data.dictionary/attributes-data.dictionary for what is required.",
        )
        var parameters: String

        func run() async throws {
            try await ASCService.updateAgeRatings(
                appId: appId,
                parameters: parameters,
                outputType: options.outputType,
            )
        }
    }
}

extension TypedId: ExpressibleByArgument { }
