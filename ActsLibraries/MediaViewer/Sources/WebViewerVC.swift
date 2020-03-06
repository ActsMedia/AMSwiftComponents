//
//  WebViewerVC.swift
//  
//  Copyright © 2020 ActsMedia. All rights reserved.
//  Created by Paul Fechner
//

#if canImport(UIKit) && canImport(WebKit)
import UIKit
import WebKit

public enum WebViewContentType: Equatable {
    case urlRequest(URLRequest)
    case webURL(URL)
    case data(Data, mimeType: String, characterEncoding: String, baseURL: URL)
    case htmlString(String, baseURL: URL?)
    case fileURL(URL)
}

open class WebViewerVC: UIViewController, WebViewContentUpdatable, WKNavigationDelegate {
    private let webView: WKWebView

    public var loadingAction: (() -> ())?
    public var loadingFinishedAction: (() -> ())?

    private var data: WebViewContentType? {
        didSet {
            if let data = data, data != oldValue {
                doUpdate(with: data)
            }
        }
    }

    public init(configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        addWebView()
    }

    func addWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addConstraints([
            view.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            view.topAnchor.constraint(equalTo: webView.topAnchor),
            view.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
        ])
        webView.navigationDelegate = self
    }

    public func update(with contentType: WebViewContentType) {
        data = contentType
    }

    private func doUpdate(with contentType: WebViewContentType) {
        switch contentType {
        case .data(let data, let mimeType, let characterEncoding, let baseURL):
           webView.load(data, mimeType: mimeType, characterEncodingName: characterEncoding, baseURL: baseURL)
        case .webURL(let url):
           webView.load(URLRequest(url: url))
        case .htmlString(let html, let baseURL):
           webView.loadHTMLString(html, baseURL: baseURL)
        case .urlRequest(let request):
           webView.load(request)
        case .fileURL(let url):
           webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingAction?()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingFinishedAction?()
    }
}

#endif
