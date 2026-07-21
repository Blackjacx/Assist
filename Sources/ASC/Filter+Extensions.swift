//
//  Filter+Extensions.swift
//  ASC
//
//  Created by Stefan Herold on 08.09.20.
//

import Foundation
import ASCKit
import ArgumentParser

extension Filter: ExpressibleByArgument {

    public init?(argument: String) {
        let splitted = argument.split(separator: "=")
        guard splitted.count == 2 else { return nil }
        self = Filter(key: String(splitted[0]), value: String(splitted[1]))
    }
}
