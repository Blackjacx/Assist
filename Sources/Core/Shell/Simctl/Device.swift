//
//  Device.swift
//
//
//  Created by Stefan Herold on 23.09.20.
//

import Foundation

public struct Device: Codable {

    public var udid: String
    public var isAvailable: Bool
    public var state: State
    public var name: String
}

public extension Device {

    enum State: String, Codable {
        case booted = "Booted"
        case shuttingDown = "Shutting Down"
        case shutdown = "Shutdown"
    }
}
