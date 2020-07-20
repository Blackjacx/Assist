//
//  Groups.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation
import ArgumentParser

extension ASC {

    struct Groups: ParsableCommand {

        static var configuration = CommandConfiguration(abstract: "Access ASC beta groups.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The name of the group to use. If nil, all groups found are used.")
        var groupName: String?

        @Argument(help: "The attribute you are interested in. [name | attributes] (default: id).")
        var attribute: String?

        func run() throws {
            let groups = try ASCService.readBetaGroups()
            groups.out(attribute, groupName: groupName)
        }
    }
}

