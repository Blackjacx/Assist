//
//  DataWrapper.swift
//  ASC
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

struct DataWrapper<T: Decodable>: Decodable {

    enum CodingKeys: String, CodingKey {
        case object = "data"
    }

    let object: T
}
