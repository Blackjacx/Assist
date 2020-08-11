//
//  DataWrapper.swift
//  ASC
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

public struct DataWrapper<T: Decodable>: Decodable {

    enum CodingKeys: String, CodingKey {
        case object = "data"
    }

    public let object: T
}
