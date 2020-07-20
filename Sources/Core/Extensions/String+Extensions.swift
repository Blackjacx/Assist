//
//  String+Extensions.swift
//  ASC
//
//  Created by Stefan Herold on 18.06.20.
//

import Foundation

public extension String {

    func nbspFiltered() -> String {
        replacingOccurrences(of: "\u{00a0}", with: " ")
    }

    func appendPathComponent(_ value: String) -> String {
        (self as NSString).appendingPathComponent(value)
    }
}
