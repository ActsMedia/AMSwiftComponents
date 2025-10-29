//
//  WebVideoViewerVC.swift
//  MediaViewer
//
//  Created for Acts Media projects requiring web-based video playback

import UIKit
import WebKit

/// Web-based video player view controller for videos that require webview playback.
///
/// This view controller is used when a video should be played in a web context
/// (e.g., Brightcove embed, custom video players) rather than native AVPlayer.
///
/// INTEGRATION:
/// - Created by MediaViewerVC.makeWebVideoVC() when video type is .webVideo
/// - Conforms to URLUpdatable protocol for video URL updates
/// - Provides loading callbacks for parent views
///
/// Usage:
/// ```swift
/// let webVideoVC = WebVideoViewerVC()
/// webVideoVC.update(with: videoURL)  // Loads and displays the video in webview
/// ```
public class WebVideoViewerVC: UIViewController, URLUpdatable {

    // MARK: - Properties

    /// The webview that displays the video content
    private let webView: WKWebView

    /// Callback invoked when video loading begins.
    /// Parent views can use this to show loading indicators.
    public var loadingAction: (() -> ())?

    /// Callback invoked when video is ready to play.
    /// Parent views can use this to hide loading indicators.
    public var loadingFinishedAction: (() -> ())?

    /// Tracks the currently loaded video URL to prevent redundant reloads.
    private var currentURL: URL?

    // MARK: - Initialization

    public init() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    // MARK: - Setup

    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.backgroundColor = .black

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - URLUpdatable Protocol

    /// Updates the video player with a new video URL and loads it in the webview.
    ///
    /// This is the primary method for loading videos. Called by parent view controllers
    /// (typically MediaViewerVC) when a video needs to be displayed in a webview.
    ///
    /// FLOW:
    /// 1. Checks if the URL is different from currently loaded URL (avoids redundant loads)
    /// 2. Creates a URLRequest and loads it in the WKWebView
    /// 3. WKNavigationDelegate callbacks handle loading states
    ///
    /// - Parameter url: The URL of the video to play
    public func update(with url: URL) {
        guard url != currentURL else { return }
        currentURL = url

        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebVideoViewerVC: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingAction?()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingFinishedAction?()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingFinishedAction?()
        print("WebVideoViewerVC: Failed to load video - \(error.localizedDescription)")
    }
}
