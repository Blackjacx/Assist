//
//  Runtime.swift
//  
//
//  Created by Stefan Herold on 23.09.20.
//

import Foundation

public struct Runtime: Codable, CustomStringConvertible {

    public var description: String { "ID: \(identifier), Name: \(name)" }

    enum CodingKeys: String, CodingKey {
        case buildVersion = "buildversion"
        case identifier
        case version
        case isAvailable
        case name
    }

    public var buildVersion: String
    public var identifier: String
    public var version: String
    public var isAvailable: Bool
    public var name: String
}
