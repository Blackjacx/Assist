//
//  AccessibilityDeclarations.swift
//  ASC
//
//  Created by Stefan Herold on 14.10.25.
//

import ArgumentParser
import ASCKit
import Foundation

extension ASC {

    /// Manage accessibility metadata for your apps per device family.
    /// https://developer.apple.com/documentation/appstoreconnectapi/accessibility-declarations
    struct AccessibilityDeclarations: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Manage accessibility metadata for your apps per device family.",
            subcommands: [
                List.self,
                Create.self,
                Update.self,
                Delete.self,
                Publish.self,
                PublishExtended.self,
            ]
        )
    }
}

extension ASC.AccessibilityDeclarations {

    /// Get a list of the accessibility declarations for a specific app.
    struct List: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Get a list of the accessibility declarations for a specific app."
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the app resource ID from the List Apps response."
        )
        var appId: String

        @Option(
            name: .shortAndLong,
            help: "Filter which is set as part of the request. See https://developer.apple.com/documentation/appstoreconnectapi/get-v1-apps-_id_-accessibilitydeclarations for possible values."
        )
        var filters: [Filter] = []

        @Option(name: .shortAndLong, help: "Number of resources to return.")
        var limit: UInt?

        @Argument(help: "The attribute you are interested in. [firstName | lastName | email | attributes] (default: id).")
        var attribute: String?

        func run() async throws {
            let declarations = try await ASCService.listAccessibilityDeclarations(
                appId: appId,
                filters: filters,
                limit: limit
            )
            declarations.out(attribute)
        }
    }

    /// Add an accessibility declaration for a specific app.
    struct Create: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Add an accessibility declaration for a specific app.",
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the app resource ID from the List Apps response.",
        )
        var appId: String

        @Option(
            name: .shortAndLong,
            help: "The device class to create the declaration for.",
        )
        var deviceFamily: AccessibilityDeclaration.DeviceFamily

        @Option(
            name: .shortAndLong,
            help: "All parameters in a single JSON hash. See https://developer.apple.com/documentation/appstoreconnectapi/accessibilitydeclarationcreaterequest/data-data.dictionary/attributes-data.dictionary for what is required.",
        )
        var parameters: String

        func run() async throws {
            let declaration = try await ASCService.createAccessibilityDeclaration(
                appId: appId,
                deviceFamily: deviceFamily,
                parameters: parameters,
            )

            [declaration].out(nil)
        }
    }

    /// Update the attributes of a specific accessibility declaration.
    struct Update: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Update the attributes of a specific accessibility declaration.",
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the accessibilityDeclarations resource ID from the List all accessibility declarations for an app response.",
        )
        var id: String

        @Option(
            name: .shortAndLong,
            help: "All parameters in a single JSON hash. See https://developer.apple.com/documentation/appstoreconnectapi/accessibilitydeclarationcreaterequest/data-data.dictionary/attributes-data.dictionary for what is required.",
        )
        var parameters: String

        func run() async throws {
            try await ASCService.updateAccessibilityDeclaration(
                id: id,
                parameters: parameters,
            )
        }
    }

    /// Delete a specific accessibility declaration.
    struct Delete: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Delete a specific accessibility declaration.",
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the accessibilityDeclarations resource ID from the List all accessibility declarations for an app response.",
        )
        var id: String

        func run() async throws {
            try await ASCService.deleteAccessibilityDeclaration(id: id)
        }
    }

    /// Same as ``Update`` but specifically for publishing a declaration.
    struct Publish: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Same as 'Update' but specifically for publishing a given declaration.",
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the accessibilityDeclarations resource ID from the List all accessibility declarations for an app response.",
        )
        var id: String

        func run() async throws {
            try await ASCService.publishAccessibilityDeclaration(
                id: id
            )
        }
    }

    /// Same as ``Publish`` but significantly more powerful.
    struct PublishExtended: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Same as 'Publish' but significantly more powerful.",
            discussion: """
            This is the tool that rules them all. It checks if existing draft 
            declarations exist and publishes them. If it cannot find any draft 
            it creates one and publishes this.  
                        
            Just specify all parameters. The parameter `publish: true` is
            automatically added.           
            """,
        )

        @OptionGroup()
        var options: ApiKeyOptions

        @Option(
            name: .shortAndLong,
            help: "An opaque resource ID that uniquely identifies the resource. Obtain the accessibilityDeclarations resource ID from the List all accessibility declarations for an app response.",
        )
        var appId: String

        @Option(
            name: .shortAndLong,
            help: "The device class to create the declaration for.",
        )
        var deviceFamily: AccessibilityDeclaration.DeviceFamily

        @Option(
            name: .shortAndLong,
            help: "All parameters in a single JSON hash. See https://developer.apple.com/documentation/appstoreconnectapi/accessibilitydeclarationcreaterequest/data-data.dictionary/attributes-data.dictionary for what is required.",
        )
        var parameters: String

        func run() async throws {
            try await ASCService.extendedPublishAccessibilityDeclaration(
                appId: appId,
                deviceFamily: deviceFamily,
                parameters: parameters,
            )
        }
    }
}

extension AccessibilityDeclaration.DeviceFamily: ExpressibleByArgument {}
