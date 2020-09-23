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
        var firstName: String? = ""
        var lastName: String? = ""
        var email: String? = ""
        var inviteType: InviteType
    }

    struct Relationships: Codable {
        var apps: Relation
        var betaGroups: Relation
        var builds: Relation
    }

    enum FilterKey: String, Codable {
        case apps
        case betaGroups
        case builds
        case email
        case firstName
        /// Possible values: EMAIL, PUBLIC_LINK
        case inviteType
        case lastName
    }
}

extension Array where Element == BetaTester {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.name, attribute: attribute)
        case "attributes": out(\.attributes, attribute: attribute)
        case "firstName": out(\.attributes.firstName, attribute: attribute)
        case "lastName": out(\.attributes.lastName, attribute: attribute)
        case "email": out(\.attributes.email, attribute: attribute)
        default: out()
        }
    }
}

extension BetaTester: Model {

    var name: String {
        var comps = PersonNameComponents()
        comps.givenName = attributes.firstName
        comps.familyName = attributes.lastName
        return PersonNameComponentsFormatter.localizedString(from: comps, style: .default, options: [])
    }
}
