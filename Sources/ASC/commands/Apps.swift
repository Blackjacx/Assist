//
//  Apps.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation
import ArgumentParser

extension ASC {

    struct Apps: ParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Access ASC apps.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Argument(help: "The attribute you want to get. [name | bundleId | locale | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            let apps = try ASCService.readApps()
            apps.out(attribute)
        }
    }
}
