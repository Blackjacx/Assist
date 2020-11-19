//
//  ApiKeysOperation.swift
//  ASC
//
//  Created by Stefan Herold on 18.11.20.
//

import Foundation
import Core

final class ApiKeysOperation: AsyncOperation {

    enum SubCommand {
        case list
        case register(key: ApiKey)
        case delete(keyId: String)
    }

    /// Collection of registered API keys
    @UserDefault("\(ProcessInfo.processId).apiKeys", defaultValue: []) private static var apiKeys: [ApiKey]

    var result: Result<[ApiKey], AscError>!

    private let subcommand: SubCommand

    init(_ subcommand: SubCommand) {
        self.subcommand = subcommand
    }

    override func main() {

        defer {
            self.state = .finished
        }

        switch subcommand {
        case .list:
            result = .success(Self.apiKeys)

        case .register(let key):
            Self.apiKeys.append(key)
            result = .success([key])

        case .delete(let keyId):
            guard let key = Self.apiKeys.first(where: { keyId == $0.keyId }) else {
                result = .failure(.apiKeyNotFound(keyId))
                return
            }
            Self.apiKeys = Self.apiKeys.filter { $0.keyId != keyId }
            result = .success([key])
        }
    }
}
