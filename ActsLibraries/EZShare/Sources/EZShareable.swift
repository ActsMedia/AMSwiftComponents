//
//  File.swift
//  
//
//  Created by Paul Fechner on 4/16/20.
//


import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol EZShareable {
    var shareItem: EZShareItem { get }
}
public protocol EZShareItem {
    var item: Any { get }
    var placeholder: Any { get }
    var subject: String? { get }
    func item(for activityType: UIActivity.ActivityType) -> Any
}

public enum EZShareType {
    #if canImport(UIKit)
    case image(UIImage)
    #endif
    case file(URL)
    case link(URL)
    case text(htmlText: String)
}

public struct EZShareData: EZShareItem {
    public let shareType: EZShareType
    public let text: String
    public let subject: String?
    public let placeholderText: String?

    public var placeholder: Any {
        if let placeholderText = placeholderText {
            return placeholderText
        }
        switch shareType {
        #if canImport(UIKit)
        case .image(let image): return image
        #endif
        case .link(let url): return url
        case .file, .text: return text
        }
    }

    public var item: Any {
        switch shareType {
        #if canImport(UIKit)
        case .image(let image): return image
        #endif
        case .link(let url): return url
        case .file(let url): return (try? Data(contentsOf: url)) as Any
        case .text: return text
        }
    }

    public init(shareType: EZShareType, text: String, subject: String? = nil, placeholderText: String? = nil) {
        self.shareType = shareType
        self.text = text
        self.subject = subject
        self.placeholderText = placeholderText
    }


    public func item(for activityType: UIActivity.ActivityType) -> Any {
        switch (activityType, shareType) {
        case (.mail, .text(let html)):
            return html
        default: return item
        }
    }
}

public class EZShareProvider: UIActivityItemProvider {
    public let shareableItem: EZShareItem

    public override var item: Any { shareableItem.item }


    public init(shareItem: EZShareItem) {
        self.shareableItem = shareItem
        super.init(placeholderItem: shareableItem.placeholder)
    }

    convenience public init(shareableItem: EZShareable) {
        self.init(shareItem: shareableItem.shareItem)
    }



    public override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let activityType = activityType else { return item }
        return shareableItem.item(for: activityType)
    }

    public override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        shareableItem.subject ?? ""
    }
}

