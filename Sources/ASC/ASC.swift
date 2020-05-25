//
//  ASC.swift
//  ASC
//
//  Created by Stefan Herold on 24.05.20.
//

import Foundation
import ArgumentParser
import Assist
import TSCBasic

public final class ASC: ParsableCommand {

    static let session = URLSession.shared

    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    public static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for accessing the App Store Connect API.",

        // Commands can define a version for automatic '--version' support.
        version: "0.0.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Groups.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Groups.self)

    static func request(token: String, path: String) -> URLRequest {

        let baseUrl = URL(string: "https://api.appstoreconnect.apple.com/v1")!
        var req = URLRequest(url: baseUrl.appendingPathComponent(path),
                             cachePolicy: .useProtocolCachePolicy,
                             timeoutInterval: 5)
        req.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": token
        ]
        return req
    }

    public init() { }
}

struct Options: ParsableArguments {

    @Option(name: .shortAndLong, help: "The ASC authorization token.")
    var token: String
}

extension ASC {

    struct Groups: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Access ASC beta groups.")

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(name: .shortAndLong, help: "The name of the group to use. If nil, all groups found are used.")
        var group: String?

        func run() throws {

            let request = ASC.request(token: options.token, path: "betaGroups")

            let json = try await { (completion: @escaping (Result<JSON, Error>) -> Void) in
                ASC.session.dataTask(with: request) { (data, response, error) in
                    if let error = error { completion(.failure(error)); return }
                    guard let data = data else { completion(.failure(NSError())); return }
                    let json = try! JSON(data: data)
                    completion(.success(json))
                }.resume()
            }
            let allGroups: [JSON] = try json.getArray("data")
            let filteredGroups: [JSON]
            if let group = group {
                filteredGroups = try allGroups.filter { try $0.getJSON("attributes").get("name") == group }
            } else {
                filteredGroups = allGroups
            }
            let ids: [String] = try filteredGroups.map { try $0.get("id") }
            ids.forEach { print($0) }
        }
    }
}
