//
//  SupportingTypes.swift
//  
//
//  Created by PJ Fechner on 2/22/21.
//

import Foundation

public protocol URLAble {
    var url: URL { get }
}

/// Basic way to provide a URL
public struct URLProvider: URLAble {
    private let baseURLString: String
    private let versionString: String

    public var url: URL {
        if versionString.isEmpty {
            return URL(string: "\(baseURLString)")!
        } else {
            return URL(string: "\(baseURLString)/\(versionString)")!
        }
    }

    init(baseURLString: String,versionString: String) {
        self.baseURLString = baseURLString
        self.versionString = versionString
    }
}

/// Errors available for networking calls
public enum NetworkError: Error {
    case missingData
    case missingJSON(String?)
    case nonHTTPResponse
    case notConnected
    case invalidType(Any?)
    case serializationError(underlyingError: Error)
    case requestError(underlyingError: Error, code: Int)
}

/// Basic enum for defining call Types
public enum CallType: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"

    /// Converts the tex to Uppercase and then compares it to the raw values.
    public static func fuzzyMake(from methodText: String, fallbackValue: CallType = .get) -> CallType {
        switch methodText.uppercased() {
        case Self.get.rawValue: return .get
        case Self.head.rawValue: return .head
        case Self.post.rawValue: return .post
        case Self.put.rawValue: return .put
        case Self.delete.rawValue: return .delete
        case Self.connect.rawValue: return .connect
        case Self.options.rawValue: return .options
        case Self.trace.rawValue: return .trace
        default: return fallbackValue
        }
    }
}
