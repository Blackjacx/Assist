//
//  Group.swift
//  ASC
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

struct Group: Codable {
    var type: String
    var id: String
    var attributes: Attributes
    var relationships: Relationships
}

extension Group {

    struct Attributes: Codable {
        var name: String
    }

    struct Relationships: Codable {
        var app: Relation
        var builds: Relation
        var betaTesters: Relation
    }

    enum FilterKey: String, Codable {
        case apps
        case builds
        case id
        case isInternalGroup
        case name
        case publicLinkEnabled
        case publicLink
    }
}

extension Array where Element == Group {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.attributes.name)
        case "attributes": out(\.attributes)
        default: out()
        }
    }
}

extension Group: Model {
    var name: String { attributes.name }
}
