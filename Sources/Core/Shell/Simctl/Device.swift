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

    enum State: Codable {
        case booted
        case shuttingDown
        case shutdown
        case unknown(String)

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            switch raw {
            case "Booted": self = .booted
            case "Shutting Down": self = .shuttingDown
            case "Shutdown": self = .shutdown
            default: self = .unknown(raw)
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .booted: try container.encode("Booted")
            case .shuttingDown: try container.encode("Shutting Down")
            case .shutdown: try container.encode("Shutdown")
            case .unknown(let raw): try container.encode(raw)
            }
        }
    }
}
