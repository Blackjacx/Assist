//
//  Filter.swift
//  ASC
//
//  Created by Stefan Herold on 08.09.20.
//

import Foundation
import ArgumentParser

struct Filter: ExpressibleByArgument {

    init?(argument: String) {
        let splitted = argument.split(separator: "=")
        guard splitted.count == 2 else { return nil }
        guard let key = splitted.first else { return nil }
        guard let value = splitted.last else { return nil }
        self.key = String(key)
        self.value = String(value)
    }
    let key: String
    let value: String
}
