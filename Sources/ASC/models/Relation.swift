//
//  Relation.swift.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation

struct Relation: Codable {
    var links: Links
}

struct Links: Codable {
    var related: URL
    var `self`: URL
}
