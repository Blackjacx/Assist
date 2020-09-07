//
//  AppStoreVersion.swift
//  ASC
//
//  Created by Stefan Herold on 07.09.20.
//

import Foundation

struct AppStoreVersion: Codable {
    var type: String
    var id: String
    var attributes: Attributes
    var relationships: Relationships
}

extension AppStoreVersion {

    enum State: String, Codable {
        case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
        case developerRejected = "DEVELOPER_REJECTED"
        case inReview = "IN_REVIEW"
        case invalidBinary = "INVALID_BINARY"
        case metadataRejected = "METADATA_REJECTED"
        case pendingAppleRelease = "PENDING_APPLE_RELEASE"
        case pendingContract = "PENDING_CONTRACT"
        case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case preorderReadyForSale = "PREORDER_READY_FOR_SALE"
        case processingForAppStore = "PROCESSING_FOR_APP_STORE"
        case readyForSale = "READY_FOR_SALE"
        case rejected = "REJECTED"
        case removedFromSale = "REMOVED_FROM_SALE"
        case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    }
    
    struct Attributes: Codable {
        var platform: String
        var versionString: String
        var appStoreState: State
        var copyright: String? = ""
        var createdDate: Date
    }

    struct Relationships: Codable {
//        var betaGroups: Relation
//        var preReleaseVersions: Relation
//        var betaAppLocalizations: Relation
//        var builds: Relation
//        var betaLicenseAgreement: Relation
//        var betaAppReviewDetail: Relation
    }
}

extension Array where Element == AppStoreVersion {

    func out(_ attribute: String?) {
        switch attribute {
        case "attributes": out(\.attributes)
        default: out(\.id)
        }
    }
}

extension AppStoreVersion: Model {
    var name: String { "" }
}
