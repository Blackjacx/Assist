//
//  Apns.swift
//  Push
//
//  Created by Stefan Herold on 11.08.20.
//

import Foundation
import ArgumentParser
import Core

extension Push {
    
    struct Apns: AsyncParsableCommand {
        
        enum Endpoint: String, ExpressibleByArgument, CaseIterable {
            case sandbox
            case production
            
            var host: String {
                switch self {
                case .sandbox: "api.sandbox.push.apple.com"
                case .production: "api.push.apple.com"
                }
            }
        }
        
        static var configuration = CommandConfiguration(
            abstract: "Access APNS, see https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns"
        )
        
        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options
        
        @Option(name: .long, help: "The path to your private key file.")
        var keyPath: String
        
        @Option(name: .long, help: "The id of the private key.")
        var keyId: String
        
        @Option(name: .long, help: "The issuer id of the key. Use the team ID of the account your app is published in.")
        var issuerId: String
        
        @Option(name: .shortAndLong, help: "The endpoint to use. `sandbox` or `production`")
        var endpoint: Endpoint
        
        @Option(name: .shortAndLong, help: "The topic. Use your bundle id of the app you want to push to.")
        var topic: String
        
        func run() async throws {
            let credentials = JWTApnsCredentials(keyPath: keyPath, keyId: keyId, issuerId: issuerId)
            try await PushService.pushViaApns(credentials: credentials,
                                              endpoint: endpoint,
                                              deviceToken: options.deviceToken,
                                              topic: topic,
                                              message: options.message)
        }
    }
}
