//
//  Service.swift
//  ASC
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation

public protocol Service {

    /// Only the service knows how to decode json from itself.
    func jsonDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
