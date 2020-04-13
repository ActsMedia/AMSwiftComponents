//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/12/20.
//

import Foundation

public protocol FileResource {
    /// The URL where the File should be saved locally
    var fileURL: URL { get }
}

public protocol RemoteResource: FileResource {
    /// The URL where the resources is available online
    var remoteURL: URL { get }
}

public protocol BundleResource: FileResource {
    /// The URL for a Bundled resource
    var bundleURL: URL { get }
}

public typealias BundledRemoteResource = RemoteResource & BundleResource

public enum CopyPolicy {
    case onlyWhenNew
    case alwaysCopy
    case manualCompare((_ current: Data, _ new: Data) -> Bool)
}

internal extension FileCopyOperation {
    convenience init(bundleResource: BundleResource, copyPolicy: CopyPolicy, errorAction: @escaping (Error) -> ()) {
        self.init(startingURL: bundleResource.bundleURL,
                          destinationURL: bundleResource.fileURL,
                          copyPolicy: copyPolicy,
                          errorAction: errorAction)
    }
}

internal extension FileDownloadOperation {

    convenience init(remoteResource: RemoteResource, copyPolicy: CopyPolicy,
        errorAction: @escaping (Error) -> (), updateAction: ((_ remoteURL: URLRequest, _ completedRatio: Float) -> ())?) {

        self.init(remoteURL: remoteResource.remoteURL,
                              destinationURL: remoteResource.fileURL,
                              copyPolicy: copyPolicy,
                              errorAction: errorAction,
                              updateAction: updateAction)
    }
}

public struct BundledRemoteResourceInfo: BundledRemoteResource {
    public let remoteURL: URL
    public let fileURL: URL
    public let bundleURL: URL

    init(remoteURL: URL, fileURL: URL, bundleURL: URL) {
        self.fileURL = fileURL
        self.bundleURL = bundleURL
        self.remoteURL = remoteURL
    }

    init?(remoteURL: URL, fileURL: URL, resourceName: String, resourceFileExtension: String, in bundle: Bundle) {
        guard let bundleURL = bundle.url(forResource: resourceName, withExtension: resourceFileExtension) else {
            return nil
        }
        self.init(remoteURL: remoteURL, fileURL: fileURL, bundleURL: bundleURL)
//        self.remoteURL = remoteURL
//        self.fileURL = fileURL
//        self.bundleURL = bundle
    }
}
