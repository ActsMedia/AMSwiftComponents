//
//  File.swift
//  
//
//  Created by Paul Fechner on 4/18/20.
//

import Foundation

/// Is able to be initialized from a list of path components and query items.
public protocol DeepLinkable {
    /// - Parameters:
    ///   - pathComponents: Path componentes from the url (e.g. *domain*/component1/component2
    ///   - queryItems: Query items from the URL (e.g. *domain/component*?query1=1&query2=2
    init?(from pathComponents: [String], and queryItems: [(String, String?)])

    var asDeepLink: URL { get }
}

/// Handles both web URLs and custom URL Schemes. E.g.
/// http(s)://www.host.com/pathComponent1/pathComponent2?queryItem=1
/// customURLScheme://pathComponent1/pathComponent2?queryItem=1
public struct EZDeepLink<T: DeepLinkable> {

    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    // Attempt to create T using components and query items from self.url
    public func generateItem() -> T? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        return T(from: components.pathComponentArray, and: components.queryPairs)
    }
}

private extension URLComponents {
    var hostIsHTTP: Bool {
        host == "http" || host == "https"
    }

     var pathComponentArray: [String] {
        let components = path.split(separator: "/").map(String.init)
        if hostIsHTTP {
            return components
        }
        else {
            return [(host ?? "")] + components
        }
    }

    var queryPairs: [(String, String?)] {
        self.queryItems?.compactMap { ($0.name, $0.value) } ?? []
    }
}
