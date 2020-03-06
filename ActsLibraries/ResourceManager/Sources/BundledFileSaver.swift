//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/12/20.
//

import Foundation

//MARK: - BundledFileSaver

public class BundledFileSaver {

    private let dispatch = DispatchQueue(label: "BundleFileSaver", qos: .default)

    let resource: [BundleResource]
    let copyPolicy: CopyPolicy
    let completionQueue: DispatchQueue
    private let progressQueue = DispatchQueue(label: "BundledFileSaverUpdateQueue", qos: .background)
    private var errors: [Error] = []

    public init(resource: [BundleResource], copyPolicy: CopyPolicy = .onlyWhenNew, completionQueue: DispatchQueue = .main) {
        self.resource = resource
        self.copyPolicy = copyPolicy
        self.completionQueue = completionQueue
    }

    func addError(error: Error) {
        progressQueue.async {
            self.errors.append(error)
        }
    }

    public func saveResources(completionQueue: DispatchQueue = .main, _ completion: @escaping (Result<Void, Error>) -> ()) {

        DispatchQueue.global().async {
            self.runOperations()
            completionQueue.async {
                if let error = self.errors.first {
                    completion(.failure(error))
                }
                else {
                    completion(.success(()))
                }
            }
        }
    }

    private func runOperations() {
        let queue = OperationQueue()
        queue.underlyingQueue = dispatch
        queue.maxConcurrentOperationCount = 8
        let operations = resource.map {
            FileCopyOperation(bundleResource: $0, copyPolicy: copyPolicy, errorAction: addError)
        }

        queue.addOperations(operations, waitUntilFinished: true)
    }
}
