//
//  File.swift
//  ASC
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

public typealias RequestClosure<T: Decodable> = (RequestResult<T>) -> Void
public typealias RequestResult<T: Decodable> = Result<T, NetworkError>

private let isDebugLogActive = false

public struct Network {

    private static let session = URLSession.shared

    public init() {}

    public func syncRequest<T: Decodable>(resource: Resource) throws -> RequestResult<T> {

        let semaphore = DispatchSemaphore(value: 0)
        var result: RequestResult<T>!

        try request(resource: resource) { (receivedResult: RequestResult<T>) in
            result = receivedResult
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }

    public func request<T: Decodable>(resource: Resource, completion: @escaping RequestClosure<T>) throws {

        var request = URLRequest(url: resource.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
        request.httpMethod = resource.method.rawValue
        request.allHTTPHeaderFields = resource.headers

        if let parameters = resource.parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }

        Self.session.dataTask(with: request) { (data, response, error) in

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(error: error)))
                return
            }

            guard (200..<400).contains(response.statusCode) else {

                var loggedError: Error? = error
                if let data = data, let failureMessage = String(data: data, encoding: .utf8) {
                    loggedError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: failureMessage])
                }
                completion(.failure(.invalidStatusCode(code: response.statusCode, error: loggedError)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData(error: error)))
                return
            }

            do {
                if isDebugLogActive {
                    let str = String(data: data, encoding: .utf8)!
                    print(str)
                }

                let decodable = try type(of: resource).service.jsonDecode(T.self, from: data)
                completion(.success(decodable))
            } catch {
                completion(.failure(.decodingFailed(error: error)))
            }
        }.resume()
    }
}
