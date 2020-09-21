//
//  Runtime.swift
//  
//
//  Created by Stefan Herold on 23.09.20.
//

import Foundation

public struct Runtime: Codable {

    enum CodingKeys: String, CodingKey {
        case buildVersion = "buildversion"
        case identifier = "identifier"
        case version = "version"
        case isAvailable = "isAvailable"
        case name = "name"
    }

    public var buildVersion: String
    public var identifier: String
    public var version: String
    public var isAvailable: Bool
    public var name: String
}
