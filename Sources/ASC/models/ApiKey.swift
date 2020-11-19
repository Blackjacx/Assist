//
//  ApiKey.swift
//  
//
//  Created by Stefan Herold on 17.11.20.
//

import Foundation

struct ApiKey: Codable {
    var name: String
    var path: String
    var keyId: String
    var issuerId: String
}
