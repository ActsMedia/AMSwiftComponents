//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/31/19.
//

import Foundation
import UIKit
import Kingfisher

public enum ImageType: Equatable {
    case url(URL)
    case image(UIImage)
    case resource(String)
    @available(iOS 13.0, macOS 10.15, *)
    case system(String)

    @available(iOS 13.0, macOS 10.15, *)
    public static var placeholderImage: UIImage! {
        UIImage(systemName: "xmark.square")!
    }

    @available(iOS 13.0, macOS 10.15, *)
    public static let placeholder: ImageType = .image(placeholderImage)
}

extension UIImageView {
    public func setImage(with imageType: ImageType) {
        switch imageType {
        case .url(let url):
            kf.setImage(with: url)
        case .image(let newImage):
            image = newImage
        case .resource(let name):
            image = UIImage(named: name)
        case .system(let name):
            if #available(iOS 13.0, macOS 10.15, *) {
                image = UIImage(systemName: name)
            } else {
                assertionFailure("Tried to use a system image on unsupported OS version")
            }
        }
    }
}

extension UIButton {
    public func setImage(with imageType: ImageType, for state: UIControl.State = .normal) {
        switch imageType {
        case .url(let url):
            kf.setImage(with: url, for: state)
        case .image(let newImage):
            setImage(newImage, for: state)
        case .resource(let name):
            guard let image = UIImage(named: name) else { return }
            setImage(image, for: state)
        case .system(let name):
            if #available(iOS 13.0, macOS 10.15, *) {
                guard let image = UIImage(systemName: name) else { return }
                setImage(image, for: state)
            } else {
                assertionFailure("Tried to use a system image on unsupported OS version")
            }
        }
    }
}
