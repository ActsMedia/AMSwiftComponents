//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/13/20.
//

import Foundation

open class ProgressDownloader: NSObject, URLSessionDownloadDelegate {

    public static func download(remoteURL: URL, urlChallenge: ((URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))? = nil, progressAction: ((_ request: URLRequest, _ ratio: Float) -> ())?, completion: @escaping (Result<URL, Error>) -> ()) -> ProgressDownloader {
        let downloader = ProgressDownloader(urlRequest: URLRequest(url: remoteURL), urlChallenge: urlChallenge, progressAction: progressAction, completion: completion)
        downloader.download()
        return downloader
    }
    public static func download(request: URLRequest, urlChallenge: ((URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))? = nil, progressAction: ((_ request: URLRequest, _ ratio: Float) -> ())?, completion: @escaping (Result<URL, Error>) -> ()) -> ProgressDownloader {
        let downloader = ProgressDownloader(urlRequest: request, urlChallenge: urlChallenge, progressAction: progressAction, completion: completion)
        downloader.download()
        return downloader
    }
    public enum ProgressDownloadError: Error {
        case wasCanceled
    }

    private let progressAction: ((_ request: URLRequest, _ ratio: Float) -> ())?
    private let completion: (Result<URL, Error>) -> ()
    private let urlChallenge: ((URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?

    private lazy var session : URLSession = {
        let config = URLSessionConfiguration.ephemeral//.background(withIdentifier: remoteURL.absoluteString)
//        config.allowsCellularAccess = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()

    private var task: URLSessionDownloadTask!
    private var request: URLRequest
    private var amountComplete: Float = 0.0
    private var progressText: String {
        return String(format: "%.01f", amountComplete * 100.0) + "%"
    }

    private var wasCanceled = false {
        didSet {
            print("was canceled")
        }
    }

    public init(urlRequest: URLRequest, urlChallenge: ((URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))? = nil, progressAction: ((_ reqest: URLRequest, _ ratio: Float) -> ())?, completion: @escaping (Result<URL, Error>) -> ()) {

        self.progressAction = progressAction
        self.completion = completion
        self.request = urlRequest
        self.urlChallenge = urlChallenge
        super.init()
        task = session.downloadTask(with: urlRequest)
    }

    public func cancel() {
        wasCanceled = true
        task?.cancel()
        session.invalidateAndCancel()
    }

    public func download() {
        amountComplete = 0.0
        task.resume()
    }

    private func sendUpdate() {
        progressAction?(request, amountComplete)
    }

    private func finish(result: Result<URL, Error>) {
        completion(result)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        amountComplete = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        sendUpdate()
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        amountComplete = (Float(fileOffset) / Float(expectedTotalBytes))
        sendUpdate()
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !wasCanceled else {
            finish(result: .failure(ProgressDownloadError.wasCanceled))
            return
        }
        if let error = error {
            finish(result: .failure(error))
        }
    }

    // this is the only required NSURLSessionDownloadDelegate method
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)  {
        amountComplete = 1.0
        sendUpdate()

        guard !wasCanceled else {
            finish(result: .failure(ProgressDownloadError.wasCanceled))
            return
        }

        finish(result: .success(location))
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let urlChallenge = urlChallenge else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let result = urlChallenge(task, challenge)
        completionHandler(result.0, result.1)
    }

}
