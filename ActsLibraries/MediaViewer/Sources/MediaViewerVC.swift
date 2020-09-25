//  MediaViewerVC.swift
//  
//  Copyright © 2020 ActsMedia. All rights reserved.
//
//  Created by Paul Fechner
//

#if canImport(UIKit)

import UIKit
import UIWrappers

public protocol MediaViewerModel {
    var type: MediaViewerType { get }
}

public protocol RemoteResourceLoading: class {
    var loadingAction: (() -> ())? { get set }
    var loadingFinishedAction: (() -> ())? { get set }
}

public protocol URLUpdatable: RemoteResourceLoading {
    func update(with url: URL)
}
public protocol WebViewContentUpdatable: RemoteResourceLoading {
    func update(with contentType: WebViewContentType)
}

public protocol ImageTypeUpdatable: RemoteResourceLoading {
    func update(with image: ImageType)
}

public enum MediaViewerType: Equatable {
    case empty
    case video(URL)
    case pdf(URL)
    case web(WebViewContentType)
    case image(ImageType)

    func isTypeEqual(to other: MediaViewerType?) -> Bool {
        switch (self, other) {
        case (.video, .video),
             (.pdf, .pdf),
             (.web, .web),
             (.image, .image): return true
        default: return false
        }
    }
}

open class MediaViewerVC<Model: MediaViewerModel>: UIViewController where Model: Equatable {

    private var currentVC: UIViewController?
    private var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var loadingBackgroundView: UIView = UIView()

    public let viewerContainerView: UIView = UIView()

    public var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            if !model.type.isTypeEqual(to: oldValue?.type) {
                mediaTypeChanged(with: model.type)
            }
            else if model != oldValue {
                mediaChanged(with: model.type)
            }
        }
    }

    private var isLoading: Bool = false {
        didSet {
            updateLoading(to: isLoading)
        }
    }

    //MARK: Setup

    open override func viewDidLoad() {
        super.viewDidLoad()
        addContainerView()
        addLoadingIndicator()
        view.setNeedsLayout()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let model = model {
            doFullUpdate(with: model)
        }
        else {
            mediaTypeChanged(with: .empty)
        }
    }

    private func addContainerView() {
        viewerContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewerContainerView)
        view.addConstraints([
            viewerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            viewerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func addLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        view.addConstraints([
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        loadingIndicator.style = .whiteLarge

        loadingBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        loadingBackgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        loadingBackgroundView.layer.cornerRadius = 8
        loadingBackgroundView.clipsToBounds = true
        view.insertSubview(loadingBackgroundView, belowSubview: loadingIndicator)

        let padding: CGFloat = 4
        view.addConstraints([
            loadingBackgroundView.leadingAnchor.constraint(equalTo: loadingIndicator.leadingAnchor, constant: -padding),
            loadingBackgroundView.trailingAnchor.constraint(equalTo: loadingIndicator.trailingAnchor, constant: padding),
            loadingBackgroundView.topAnchor.constraint(equalTo: loadingIndicator.topAnchor, constant: -padding),
            loadingBackgroundView.bottomAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: padding),
        ])
    }

    //MARK: Updates

    open func doFullUpdate(with model: Model) {
        mediaTypeChanged(with: model.type)
    }

    private func updateViewer(with url: URL) {
        guard let updatable = currentVC as? URLUpdatable else {
            assertionFailure("Tried to update the viewer without a relevant `currentVC` being present")
            return
        }
        updatable.update(with: url)
    }

    private func updateViewer(with webContent: WebViewContentType) {
        guard let updatable = currentVC as? WebViewContentUpdatable else {
            assertionFailure("Tried to update the viewer without a relevant `currentVC` being present")
            return
        }
        updatable.update(with: webContent)
    }

    private func updateViewer(with image: ImageType) {

        guard let updatable = currentVC as? ImageTypeUpdatable else {
            assertionFailure("Tried to update the viewer without a relevant `currentVC` being present")
            return
        }
        updatable.update(with: image)
    }

    //MARK: ChangeReactions

    private func mediaTypeChanged(with type: MediaViewerType) {
        setupMediaVC(makeVC(for: type))
        mediaChanged(with: type)
    }

    private func mediaChanged(with type: MediaViewerType) {
        switch type {
        case .empty: return
        case .video(let url),
             .pdf(let url): updateViewer(with: url)
        case .web(let webContent): updateViewer(with: webContent)
        case .image(let image): updateViewer(with: image)
        }
    }

    //MARK: Loading

    private func setupLoadingActions(for resourceLoader: RemoteResourceLoading) {
        resourceLoader.loadingAction = { [weak self] in
            self?.isLoading = true
        }
        resourceLoader.loadingFinishedAction = { [weak self] in
            self?.isLoading = false
        }
    }

    public func updateLoading(to isLoading: Bool) {
        loadingIndicator.isHidden = !isLoading
        loadingBackgroundView.isHidden = !isLoading
        if isLoading {
            loadingIndicator.startAnimating()
        }
        else {
            loadingIndicator.stopAnimating()
        }
    }

    //MARK: VC Management

    private func setupMediaVC(_ newVC: UIViewController & RemoteResourceLoading) {
        guard currentVC.self != newVC.self else {
            // If we're using the same VC, we don't need to do the setup.
            return
        }
        resetCurrentVC()
        currentVC = newVC
        newVC.view.backgroundColor = UIColor.black
//        newVC.willMove(toParent: self)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        viewerContainerView.addSubview(newVC.view)
        viewerContainerView.addConstraints([
            viewerContainerView.leadingAnchor.constraint(equalTo: newVC.view.leadingAnchor),
            viewerContainerView.trailingAnchor.constraint(equalTo: newVC.view.trailingAnchor),
            viewerContainerView.topAnchor.constraint(equalTo: newVC.view.topAnchor),
            viewerContainerView.bottomAnchor.constraint(equalTo: newVC.view.bottomAnchor),
        ])
//        self.addChild(newVC)
//        newVC.didMove(toParent: self)

        setupLoadingActions(for: newVC)
        updateLoading(to: isLoading)
    }

    private func resetCurrentVC() {
        guard currentVC != nil else { return }
        currentVC?.view.removeFromSuperview()
        currentVC = nil
    }

    private func makeVC(for mediaType: MediaViewerType) -> UIViewController & RemoteResourceLoading {
        switch mediaType {
        case .empty: return makeEmptyVC()
        case .video: return makeVideoVC()
        case .pdf: return makePDFVC()
        case .web: return makeWebVC()
        case .image: return makeImageVC()
        }
    }

    //MARK: VC Creation

    open func makeEmptyVC() -> UIViewController & RemoteResourceLoading {
        return EmptyStateVC()
    }

    open func makeVideoVC() -> UIViewController & URLUpdatable {
        return VideoViewerVC()
    }

    open func makePDFVC() -> UIViewController & URLUpdatable {
        #if canImport(PDFKit)
        return PDFViewerVC()
        #else
        return EmptyURLVC()
        #endif
    }

    open func makeWebVC() -> UIViewController & WebViewContentUpdatable {
        return WebViewerVC()
    }

    open func makeImageVC() -> UIViewController & ImageTypeUpdatable {
        return ImageViewerVC()
    }
}

#endif
