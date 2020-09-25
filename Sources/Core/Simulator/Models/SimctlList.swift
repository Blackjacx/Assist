//
//  SimctlList.swift
//
//
//  Created by Stefan Herold on 23.09.20.
//

import Foundation

public struct SimctlList: Codable {

    public var runtimes: [Runtime]
    public var devices: [String: [Device]]
}
