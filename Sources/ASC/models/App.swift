//
//  App.swift
//  ASC
//
//  Created by Stefan Herold on 18.06.20.
//

import Foundation

struct App: Codable {
    var type: String
    var id: String
    var attributes: Attributes
    var relationships: Relationships
}

extension App {

    struct Attributes: Codable {
        var name: String
        var bundleId: String
        var sku: String
        var primaryLocale: String
    }

    struct Relationships: Codable {
        var betaGroups: Relation
        var preReleaseVersions: Relation
        var betaAppLocalizations: Relation
        var builds: Relation
        var betaLicenseAgreement: Relation
        var betaAppReviewDetail: Relation
    }
}

extension Array where Element == App {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.attributes.name)
        case "attributes": out(\.attributes)
        case "bundleId": out(\.attributes.bundleId)
        case "locale": out(\.attributes.primaryLocale)
        default: out(\.id)
        }
    }
}

extension App: Model {
    var name: String { attributes.name }
}
