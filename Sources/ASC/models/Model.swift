//
//  Model.swift
//  ASC
//
//  Created by Stefan Herold on 18.06.20.
//

import Foundation

protocol Model {
    var id: String { get }
    var name: String { get }
}

extension Array where Self.Element: Model {

    func out<T>(_ keyPath: KeyPath<Element, T>) {
//        map { $0[keyPath: keyPath] }.forEach { print( $0 ) }
        let joined = map { "\($0[keyPath: keyPath])" }.joined(separator: " ")
        print(joined)
    }

    var allIds: [String] {
        map { $0.id }
    }

    var allNames: [String] {
        map { $0.name }
    }

    func allIds(for name: String?) -> [String] {
        var filtered = self
        if let name = name {
            filtered = filter { $0.name.nbspFiltered() == name.nbspFiltered() }
        }
        return filtered.map { $0.id }
    }

    func allNames(for name: String?) -> [String] {
        var filtered = self
        if let name = name {
            filtered = filter { $0.name.nbspFiltered() == name.nbspFiltered() }
        }
        return filtered.map { $0.name }
    }
}
