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
        guard let key = splitted.first else { return nil }
        guard let value = splitted.last else { return nil }
        self = Filter(key: String(key), value: String(value))
    }
}
