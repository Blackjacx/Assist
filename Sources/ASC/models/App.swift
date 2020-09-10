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

    enum FilterKey: String, Codable {
        case bundleId
        case id
        case name
        case sku
        case appStoreVersions
        /// Possible values: IOS, MAC_OS, TV_OS
        case appStoreVersionsPlatform = "appStoreVersions.platform"
        /// Possible values: DEVELOPER_REMOVED_FROM_SALE, DEVELOPER_REJECTED, IN_REVIEW, INVALID_BINARY,
        /// METADATA_REJECTED, PENDING_APPLE_RELEASE, PENDING_CONTRACT, PENDING_DEVELOPER_RELEASE,
        /// PREPARE_FOR_SUBMISSION, PREORDER_READY_FOR_SALE, PROCESSING_FOR_APP_STORE, READY_FOR_SALE, REJECTED,
        /// REMOVED_FROM_SALE, WAITING_FOR_EXPORT_COMPLIANCE, WAITING_FOR_REVIEW, REPLACED_WITH_NEW_VERSION
        case appStoreVersionsAppStoreState = "appStoreVersions.appStoreState"
    }
}

extension Array where Element == App {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.attributes.name)
        case "attributes": out(\.attributes)
        case "bundleId": out(\.attributes.bundleId)
        case "locale": out(\.attributes.primaryLocale)
        default: out()
        }
    }
}

extension App: Model {
    var name: String { attributes.name }
}
