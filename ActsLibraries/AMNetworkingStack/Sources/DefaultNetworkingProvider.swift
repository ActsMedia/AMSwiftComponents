//
//  DefaultNetworkingProvider.swift
//
//  Created by PJ Fechner on 2/22/21.
//

import Foundation

protocol BasicJSONNetworkingProvider: NetworkingProvider {

    var defaultHeaders: [String:String] { get }
}

extension BasicJSONNetworkingProvider {

    var defaultHeaders: [String: String]  {
        ["Content-Type":"application/json"]
    }

    func enqueueRequest<Response>(_ request: URLRequest, decoder: JSONDecoder, completion: @escaping (Result<Response, Error>) -> ()) where Response : Decodable {
        var mutableRequest = request
        defaultHeaders.forEach {
            mutableRequest.addValue($1, forHTTPHeaderField: $0)
        }
        checkConnection { (isConnected) in
            guard isConnected else {
                completion(.failure(NetworkError.notConnected))
                return
            }
            self.startDataTask(mutableRequest, decoder: decoder, completion: completion)
        }
    }
}
