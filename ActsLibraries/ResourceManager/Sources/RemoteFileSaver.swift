//
//  RemoteFileSaver.swift
//  
//
//  Created by Paul Fechner on 2/12/20.
//

import Foundation

//MARK: - RemoteFileSaver

public class RemoteFileSaver {

    private let dispatch = DispatchQueue(label: "RemoteFileSaver", qos: .default)
    let resource: [(RemoteResource, CopyPolicy)]
    let completionQueue: DispatchQueue
    private let progressQueue = DispatchQueue(label: "RemoteFileSaverUpdateQueue", qos: .background)
    private var errors: [Error] = []
    private let updateAction: ((URL, Float) -> ())?

    private var canceling = false
    private var runningQueue: OperationQueue?

    public init(resource: [(RemoteResource, CopyPolicy)], completionQueue: DispatchQueue = .main, updateAction: ((URL, Float) -> ())? = nil) {
        self.resource = resource
        self.completionQueue = completionQueue
        self.updateAction = updateAction
    }

    private func addError(error: Error) {
        progressQueue.async {
            self.errors.append(error)
        }
    }

    private func sendUpdate(_ request: URLRequest, _ ratio: Float) {
        guard !canceling else { return }
        guard let updateAction = updateAction, let url = request.url else { return }
        completionQueue.async {
            updateAction(url, ratio)
        }
    }

    public func cancel() {
        canceling = true
        runningQueue?.cancelAllOperations()
    }

    public func downloadResources(completionQueue: DispatchQueue = .main, _ completion: @escaping (Result<Void, Error>) -> ()) {

        DispatchQueue.global().async {
            self.runOperations()
            completionQueue.async {
                if self.canceling {
                    self.resource.forEach{try? $0.0.deleteSavedFile() }
                    completion(.success(()))
                }
                else if let error = self.errors.first {
                    completion(.failure(error))
                }
                else {
                    completion(.success(()))
                }
            }
        }
    }

    private func runOperations() {
        let newQueue = OperationQueue()

        newQueue.underlyingQueue = dispatch
        newQueue.maxConcurrentOperationCount = 8
        let operations = resource.map {
            FileDownloadOperation(remoteResource: $0.0, copyPolicy: $0.1, errorAction: addError(error:), updateAction: sendUpdate)
        }
        self.runningQueue = newQueue
        newQueue.addOperations(operations, waitUntilFinished: true)
    }
}

extension FileManager {
    func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    func copyItem(at originURL: URL, to destinationURL: URL) throws {
        try copyItem(atPath: originURL.path, toPath: destinationURL.path)
    }
}
