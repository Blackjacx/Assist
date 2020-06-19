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
        var app: App
        var builds: Builds
        var betaTesters: BetaTesters
    }
}

extension Array where Element == Group {

    func out(_ attribute: String?, groupName: String?) {

        var filtered = self
        if let groupName = groupName {
            filtered = filter { $0.name.nbspFiltered() == groupName.nbspFiltered() }
        }

        switch attribute {
        case "name": filtered.out(\.attributes.name)
        case "attributes": filtered.out(\.attributes)
        default: filtered.out(\.id)
        }
    }
}

extension Group: Model {
    var name: String { attributes.name }
}

extension Group.Relationships {

    struct App: Codable {
        var links: Links
    }

    struct Builds: Codable {
        var links: Links
    }

    struct BetaTesters: Codable {
        var links: Links
    }
}
