//
//  Resource.swift
//  Core
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

/// Describes everything to operate on network resources. Encapsulates the details to form a network request. Conform
/// an enum to it to implement multiple endpoints using the enum's cases.
public protocol Resource {

    static var service: Service { get }
    static var host: String { get }

    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var shouldAuthorize: Bool { get }
}

extension Resource {

    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.host
        components.path = path
        components.queryItems = queryItems
        return components.url!
    }
}
