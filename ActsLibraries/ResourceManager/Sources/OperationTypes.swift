//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/13/20.
//

import Foundation

//MARK: - CopyOperation

internal class FileCopyOperation: ConcurrentOperation {
    private let startingURL: URL
    private let destinationURL: URL
    private let copyPolicy: CopyPolicy
    private let errorAction: (Error) -> ()

    init(startingURL: URL, destinationURL: URL, copyPolicy: CopyPolicy, errorAction: @escaping (Error) -> ()) {
        self.startingURL = startingURL
        self.destinationURL = destinationURL
        self.copyPolicy = copyPolicy
        self.errorAction = errorAction
    }

    override func execute() {
        let fileExists = FileManager.default.fileExists(at: destinationURL)
        if fileExists, case CopyPolicy.onlyWhenNew = copyPolicy { return }

        do {
            try self.copyPolicy.copy(fileExists: fileExists, startingURL: startingURL, destinationURL: destinationURL)
        } catch {
            print(error)
            errorAction(error)
        }
    }
}

//MARK: - DownloadOperation

internal class FileDownloadOperation: AsyncOperation {
    private let remoteURL: URL
    private let destinationURL: URL
    private let copyPolicy: CopyPolicy
    private let urlChallenge: ((URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
    private let errorAction: (Error) -> ()
    private let updateAction: ((_ reqest: URLRequest, _ completedRatio: Float) -> ())?
    private var downloader: ProgressDownloader?

    init(remoteURL: URL,
         destinationURL: URL,
         copyPolicy: CopyPolicy,
         urlChallenge: ((URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?,
         errorAction: @escaping (Error) -> (),
         updateAction: ((_ reqest: URLRequest, _ completedRatio: Float) -> ())?) {
        self.remoteURL = remoteURL
        self.destinationURL = destinationURL
        self.copyPolicy = copyPolicy
        self.urlChallenge = urlChallenge
        self.errorAction = errorAction
        self.updateAction = updateAction
    }

    override func execute(completion: @escaping () -> ()) {
        let fileExists = FileManager.default.fileExists(at: destinationURL)
        if fileExists, case CopyPolicy.onlyWhenNew = copyPolicy {
            completion()
            return
        }
        downloader = ProgressDownloader.download(remoteURL: remoteURL, urlChallenge: urlChallenge, progressAction: updateAction) { (result) in
            defer { completion() }

            switch result {
            case .failure(let error):
                print(error)
                self.errorAction(error)
            case.success(let temporaryURL):
                do {
                    try self.copyPolicy.copy(fileExists: fileExists, startingURL: temporaryURL, destinationURL: self.destinationURL)
                }
                catch {
                    print(error)
                    self.errorAction(error)
                }
            }
        }
    }

    override func cancel() {
        super.cancel()
        downloader?.cancel()
    }
}

// MARK: File Copy Handeling
private extension CopyPolicy {
    func copy(fileExists: Bool, startingURL: URL, destinationURL: URL) throws {
        if !fileExists {
            let directoryURL = destinationURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: [:])
        }

        switch self {
        case .onlyWhenNew:
            guard !fileExists else { return }
            _ = try FileManager.default.copyItem(at: startingURL, to: destinationURL)
        case .alwaysCopy:
            if fileExists {
                try? FileManager.default.removeItem(at: destinationURL)
            }
            _ = try FileManager.default.copyItem(at: startingURL, to: destinationURL)
        case .manualCompare(let comparer):
            if let newData = try? Data(contentsOf: startingURL), let currentData = try? Data(contentsOf: destinationURL) {
                guard comparer(currentData, newData) else { return }
            }
            else {
                print("Could not compare data from \(startingURL) and \(destinationURL)")
                print("Will continue with copy")
            }
            if fileExists {
                try? FileManager.default.removeItem(at: destinationURL)
            }
            _ = try FileManager.default.copyItem(at: startingURL, to: destinationURL)
        }
    }
}

