// NetworkingProvider.swift


// Copyright © 2017 ActsMedia. All rights reserved.

import Foundation
import Connectivity

/// Basic contract for a Networking provider
public protocol NetworkingProvider {
    static var shared: Self { get }
    var connectivity: Connectivity { get }
    var urlProvider: URLAble { get }

    /// Simplest version of JSONDecodable networking request
    func enqueueRequest<Response: Decodable>(_ request: URLRequest, decoder: JSONDecoder, completion: @escaping (Result<Response, Error>) -> ())
    ///
    func checkConnection(_ isConnectedCompletion: @escaping (Bool) ->())
}

//MARK: - Connectivity
extension NetworkingProvider {
    func checkConnection(_ isConnectedCompletion: @escaping (Bool) ->()) {
        connectivity.checkConnectivity { isConnectedCompletion($0.isConnected) }
    }
}

//MARK: - Request Convenience

public extension NetworkingProvider {

    /// Simplest version of JSONDecodable networking request
    /// uses basic `JSONDecoder()` as `decoder`
    func enqueueRequest<Response: Decodable>(_ request: URLRequest, completion: @escaping (Result<Response, Error>) -> ()) {
        enqueueRequest(request, decoder: JSONDecoder(), completion: completion)
    }

    /// Typical call with a JSONEncodable Body
    func enqueueRequest<Body: Encodable, Response: Decodable>(urlExtension: String, body: Body, method: CallType,
                                                              additionalHeaders: [String:String] = [:], encoder: JSONEncoder = JSONEncoder(),
                                                              decoder: JSONDecoder = JSONDecoder(), completion: @escaping ((Result<Response, Error>) -> ())) {
        var urlRequest = URLRequest(url: urlProvider.url.appendingPathComponent(urlExtension))
        additionalHeaders.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)}
        urlRequest.httpMethod = method.rawValue
        do {
            urlRequest.httpBody = try encoder.encode(body)
            enqueueRequest(urlRequest, decoder: decoder, completion: completion)
        }
        catch {
            completion(.failure(error))
        }
    }

    /// Typical call with no Body
    func enqueueRequest<Response: Decodable>(urlExtension: String, method: CallType,
                                             additionalHeaders: [String:String] = [:],
                                             decoder: JSONDecoder = JSONDecoder(), completion: @escaping ((Result<Response, Error>) -> ())) {
        var urlRequest = URLRequest(url: urlProvider.url.appendingPathComponent(urlExtension))
        additionalHeaders.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)}
        urlRequest.httpMethod = method.rawValue
        enqueueRequest(urlRequest, decoder: decoder, completion: completion)
    }
}

//MARK: - Request Handling

public extension NetworkingProvider {
    
    /// Starts a data task with `URLSession.shared.dataTask`
    func startDataTask<Response: Decodable>(_ request: URLRequest, decoder: JSONDecoder, completion: @escaping (Result<Response, Error>) -> ()) {

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, decoder: decoder, completion: completion)
        }
        .resume()
    }

    /// Starts an upload task with `URLSession.shared.uploadTask`
    func startUploadTask<Response: Decodable>(_ request: URLRequest, data: Data, decoder: JSONDecoder, completion: @escaping (Result<Response, Error>) -> ()) {

        URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
            handleResponse(data: data, response: response, error: error, decoder: decoder, completion: completion)
        }
        .resume()
    }

    private func handleResponse<Response: Decodable>(data: Data?, response: URLResponse?, error: Error?, decoder: JSONDecoder, completion: @escaping (Result<Response, Error>) -> ()) {
        if let error = error {
            completion(.failure(NetworkError.requestError(underlyingError: error, code: (response as? HTTPURLResponse)?.statusCode ?? 0)))
            return
        }
        else if let data = data {
            do {
                let response = try decoder.decode(Response.self, from: data)
                completion(.success(response))
            }
            catch {
                #if DEBUG
                print("error: \(error)")
                let json = String(data: data, encoding: .utf8)
                print("InvalidJson: \n\(json ?? "??")")
                #endif
                completion(.failure(error))
            }
        }
        else {
            completion(.failure(NetworkError.missingData))
        }
    }
}
