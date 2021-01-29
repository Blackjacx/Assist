//
//  Relation.swift.swift
//  ASC
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation

struct Relation: Codable, Hashable, Equatable {
    var links: Links
}

struct Links: Codable, Hashable, Equatable {
    var related: URL
    var `self`: URL
}
