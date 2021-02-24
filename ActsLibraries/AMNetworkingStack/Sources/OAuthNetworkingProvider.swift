//
//  DefaultNetworkingProvider.swift
//
//  Created by PJ Fechner on 2/22/21.
//

import Foundation

protocol OAuthInfoProvider {

    var applicationID: String { get }
    var secret: String { get }
    var includeAppAuthHeaders: Bool { get }

    func set(token: String) throws
    func get() -> String?

}
protocol OAuthNetworkingProvider: NetworkingProvider {

    var defaultHeaders: [String: String] { get }
    var infoProvider: OAuthInfoProvider { get }
    var sendApplicationHeaders: Bool { get }
}

extension OAuthNetworkingProvider {

    var defaultHeaders: [String: String] {
        var headers: [String: String]
        if sendApplicationHeaders {
            headers = oauthHeaders
        } else {
            headers = passwordAuthHeaders
        }
        headers["Content-Type"] = "application/json"
        return headers
    }

    private var oauthHeaders: [String: String] {
        [
            "application id": infoProvider.applicationID,
            "secret": infoProvider.secret
        ]
    }

    private var passwordAuthHeaders: [String: String ] {
        [
            "Authorization":"Bearer " + (infoProvider.get() ?? "")
        ]
    }

    private func checkConnection(_ isConnectedCompletion: @escaping (Bool) ->()) {
        connectivity.checkConnectivity { isConnectedCompletion($0.isConnected) }
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
