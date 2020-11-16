//
//  BetaTesterInvitationResponse.swift
//  ASC
//
//  Created by Stefan Herold on 16.11.20.
//

import Foundation

struct BetaTesterInvitationResponse: Codable {
    var id: String
    var type: String
}

extension Array where Element == BetaTesterInvitationResponse {

    func out(_ attribute: String?) {
        out()
    }
}

extension BetaTesterInvitationResponse: Model {

    var name: String {
        "N/A"
    }
}
