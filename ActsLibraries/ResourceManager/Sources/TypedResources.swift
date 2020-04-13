//
//  TypedResource.swift
//  3mCosmo
//
//  Created by Paul Fechner on 4/1/20.
//  Copyright © 2020 MMM. All rights reserved.
//

import Foundation

public protocol AnyTypedResource: FileResource { }

public protocol TypedResource: AnyTypedResource {
    associatedtype Model: Codable
    func decodeModel() throws -> Model
    var decoder: JSONDecoder { get }
}

/// A Resource wrapper for a JSON Backed Codable Model
/// Used for resources with both a bundled and remote version of the data
public struct BundledRemoteTypedResource<Model: Codable>: TypedResource, BundledRemoteResource {
    public let fileURL: URL
    public let bundleURL: URL
    public let remoteURL: URL
    public let decoder: JSONDecoder

    public init(fileURL: URL, bundleURL: URL, remoteURL: URL, decoder: JSONDecoder = JSONDecoder()) {
        self.bundleURL = bundleURL
        self.remoteURL = remoteURL
        self.fileURL = fileURL
        self.decoder = decoder
    }
}

/// A Resource wrapper for a JSON Backed Codable Model
/// Used for resources with only an existing Remote version of the data
public struct RemoteTypedResource<Model: Codable>: TypedResource, RemoteResource {
    public let fileURL: URL
    public let remoteURL: URL
    public let decoder: JSONDecoder

    public init(fileURL: URL, remoteURL: URL,  decoder: JSONDecoder = JSONDecoder()) {
        self.remoteURL = remoteURL
        self.fileURL = fileURL
        self.decoder = decoder
    }
}

/// A Resource wrapper for a JSON Backed Codable Model
/// Used for resources with only an existing Bundle version of the data
public struct BundleTypedResource<Model: Codable>: TypedResource, BundleResource {
    public let fileURL: URL
    public let bundleURL: URL
    public let decoder: JSONDecoder

    public init(fileURL: URL, bundleURL: URL, decoder: JSONDecoder = JSONDecoder()) {
        self.bundleURL = bundleURL
        self.fileURL = fileURL
        self.decoder = decoder
    }
}


public extension TypedResource where Self: BundledRemoteResource {
    /// Decodes the related model prefering the file, then bundle, then remote URL
    func decodeModel() throws -> Model {
        if let localData = try? Data(contentsOf: fileURL) {
            print("Building local version")
            return try decoder.decode(Model.self, from: localData)
        }
        else if let bundleData = try? Data(contentsOf: bundleURL) {
            print("Building Bundle version")
            return try decoder.decode(Model.self, from: bundleData)
        }
        else {
            print("Attempting to build from remote version")
            let remoteData = try Data(contentsOf: remoteURL)
            return try decoder.decode(Model.self, from: remoteData)
        }
    }
}

public extension TypedResource where Self: RemoteResource {
    /// Decodes the related model prefering the file, then bundle, then remove URL
    func decodeModel() throws -> Model {
        if let localData = try? Data(contentsOf: fileURL) {
            print("Building local version")
            return try decoder.decode(Model.self, from: localData)
        }
        else {
            print("Attempting to build from remote version")
            let remoteData = try Data(contentsOf: remoteURL)
            return try decoder.decode(Model.self, from: remoteData)
        }
    }
}

public extension TypedResource where Self: BundleResource {
    /// Decodes the related model prefering the file, then bundle, then remove URL
    func decodeModel() throws -> Model {
        if let localData = try? Data(contentsOf: fileURL) {
            print("Building local version")
            return try decoder.decode(Model.self, from: localData)
        }
        else {
            print("Attempting to build from Bundle version")
            let bundleData = try Data(contentsOf: bundleURL)
            return try decoder.decode(Model.self, from: bundleData)
        }
    }
}


