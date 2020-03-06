//
//  ImageViewerVC.swift
//  
//  Copyright © 2020 ActsMedia. All rights reserved.
//  Created by Paul Fechner
//

#if canImport(UIKit)

import UIKit
import UIWrappers

open class ImageViewerVC: UIViewController, ImageTypeUpdatable {
    public var loadingAction: (() -> ())?
    public var loadingFinishedAction: (() -> ())?

    let imageView: UIImageView = UIImageView()

    open override func viewDidLoad() {
        super.viewDidLoad()
        addImageView()
        setupImageView()
    }

    private func addImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addConstraints([
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            view.topAnchor.constraint(equalTo: imageView.topAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
    }

    open func update(with image: ImageType) {
        imageView.setImage(with: image)
        loadingFinishedAction?()
    }
}

#endif
