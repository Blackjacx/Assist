//
//  NetworkError.swift
//  Core
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

public enum NetworkError: Error {
    case invalidResponse(error: Error?)
    case invalidStatusCode(code: Int, error: Error?)
    case noData(error: Error?)
    case decodingFailed(error: Error?)
}
