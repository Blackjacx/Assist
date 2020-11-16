//
//  AscError.swift
//  ASC
//
//  Created by Stefan Herold on 09.09.20.
//

import Foundation

enum AscError: Error {
    case noDataProvided(_ type: String)
    case noUserFound(_ email: String)
    case requestFailed(underlyingErrors: [Error])
}
