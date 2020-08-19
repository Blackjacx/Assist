//
//  Fcm.swift
//  Push
//
//  Created by Stefan Herold on 11.08.20.
//

import Foundation
import ArgumentParser
import Core

extension Push {

    struct Fcm: ParsableCommand {

      static var configuration = CommandConfiguration(
        abstract: "Access FCM, see https://firebase.google.com/docs/cloud-messaging"
      )

      // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
      // `ParsableArguments` type.
      @OptionGroup()
      var options: Options

      @Option(name: .long, help: "The path to your service-account json file.")
      var serviceAccountJsonPath: String

      func run() throws {

        try PushService.pushViaFcm(deviceToken: options.deviceToken, 
                                   message: options.message,
                                   serviceAccountJsonPath: serviceAccountJsonPath)
      }
    }
}
