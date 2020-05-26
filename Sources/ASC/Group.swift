//
//  Group.swift
//  ASC
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

struct Group: Codable {

    var type: String
    var id: String
    var attributes: GroupAttributes
}

struct GroupAttributes: Codable {

    var name: String
}
