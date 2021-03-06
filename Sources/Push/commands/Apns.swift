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

    struct Apns: ParsableCommand {

      enum Endpoint: String, ExpressibleByArgument, CaseIterable {
        case sandbox
        case production

        var host: String {
          switch self {
          case .sandbox: return "api.sandbox.push.apple.com"
          case .production: return "api.push.apple.com"
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

      @Option(name: .shortAndLong, help: "The topic. User your bundle id of the app you want to push to.")
      var topic: String

      func run() throws {
        try PushService.pushViaApns(credentials: JWTApnsCredentials(keyPath: keyPath, keyId: keyId, issuerId: issuerId),
                                    endpoint: endpoint, 
                                    deviceToken: options.deviceToken, 
                                    topic: topic,
                                    message: options.message)
      }
    }
}
