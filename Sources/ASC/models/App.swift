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
        var betaGroups: BetaGroups
        var preReleaseVersions: PreReleaseVersions
        var betaAppLocalizations: BetaAppLocalizations
        var builds: Builds
        var betaLicenseAgreement: BetaLicenseAgreement
        var betaAppReviewDetail: BetaAppReviewDetail
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

extension App.Relationships {

    struct BetaTesters: Codable {
        var links: Links
    }

    struct BetaGroups: Codable {
        var links: Links
    }

    struct PreReleaseVersions: Codable {
        var links: Links
    }

    struct BetaAppLocalizations: Codable {
        var links: Links
    }

    struct Builds: Codable {
        var links: Links
    }

    struct BetaLicenseAgreement: Codable {
        var links: Links
    }

    struct BetaAppReviewDetail: Codable {
        var links: Links
    }
}
