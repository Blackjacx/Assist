//
//  BetaTester.swift
//  ASC
//
//  Created by Stefan Herold on 16.07.20.
//

import Foundation

struct BetaTester: Codable {
    var type: String
    var id: String
    var attributes: Attributes
    var relationships: Relationships
}

extension BetaTester {

    struct Attributes: Codable {
        var firstName: String
        var lastName: String
        var email: String
        var inviteType: InviteType
    }

    struct Relationships: Codable {
        var apps: Apps
        var betaGroups: BetaGroups
        var builds: Builds
    }
}

extension BetaTester {

    func out(_ attribute: String?) {
        switch attribute {
        case "attributes": print( attributes )
        case "firstName": print( attributes.firstName )
        case "lastName": print( attributes.lastName )
        case "email": print( attributes.email )
        default: print( id )
        }
    }
}

extension BetaTester: Model {

    var name: String {
        var comps = PersonNameComponents()
        comps.givenName = attributes.firstName
        comps.familyName = attributes.lastName
        return PersonNameComponentsFormatter().string(from: comps)
    }
}

extension BetaTester.Relationships {

    struct Apps: Codable {
        var links: Links
    }

    struct BetaGroups: Codable {
        var links: Links
    }

    struct Builds: Codable {
        var links: Links
    }
}

