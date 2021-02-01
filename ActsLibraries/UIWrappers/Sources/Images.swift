//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/31/19.
//

import Foundation
import UIKit
import Kingfisher
import SFSafeSymbols

public enum ImageType: Equatable {
    case url(URL)
    case image(UIImage)
    case resource(String)
    case system(SFSymbol)

    private static var placeholderImage: UIImage {
        UIImage(systemSymbol: .xmarkSquare)
    }

    public static let placeholder: ImageType = .image(placeholderImage)

    public static func makeOrPlaceholder(from urlString: String?) -> ImageType {
        urlString.map { makeOrPlaceholder(from: URL(string: $0)) } ?? .placeholder
    }

    public static func makeOrPlaceholder(from url: URL?) -> ImageType {
        url.map(ImageType.url) ?? .placeholder
    }
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
        case .system(let systemSymbol):
            if #available(iOS 13.0, macOS 10.15, *) {
                image = UIImage(systemSymbol: systemSymbol)
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
        case .system(let systemSymbol):
            setImage(UIImage(systemSymbol: systemSymbol), for: state)
        }
    }
}
