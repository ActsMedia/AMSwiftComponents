//
//  AttributedLabel.swift
//  3mCosmo
//
//  Created by Paul Fechner on 12/11/19.
//  Copyright © 2019 MMM. All rights reserved.
//

import UIKit

@IBDesignable
open class AttributedLabel: UILabel {

    @IBInspectable
    open var strokeWidth: CGFloat = 0 {
        didSet {
            if oldValue != strokeWidth { updateAttributes() }
        }
    }

    @IBInspectable
    open var strokeColor: UIColor = .black {
        didSet {
            if oldValue != strokeColor { updateAttributes() }
        }
    }

    @IBInspectable
    open var foregroundColor: UIColor = .black {
        didSet {
            if oldValue != foregroundColor { updateAttributes() }
        }
    }
    
    open override var text: String? {
        get {
            attributedText?.string
        }
        set {
            attributedText = attributedString(from: newValue)
        }
    }

    private var attributes: [NSAttributedString.Key : Any] = [:] {
        didSet {
            updateUpdateCurrentLabel()
        }
    }

    private func updateAttributes() {
        attributes = [.strokeWidth: strokeWidth,
                      .strokeColor: strokeColor,
                      .foregroundColor: foregroundColor,
                      .font: font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)]
    }

    private func attributedString(from string: String?) -> NSAttributedString? {
        guard let string = string else { return nil }
        return NSAttributedString(string: string, attributes: attributes)
    }

    private func updateUpdateCurrentLabel(newText: NSAttributedString? = nil) {

        guard let textToUse = newText ?? attributedText else { return }

        let mutableAttributed = NSMutableAttributedString(attributedString: textToUse)
        mutableAttributed.addAttributes(attributes: attributes)
        attributedText = attributedString(from: attributedText?.string)
    }

    open func setCustomAttributedText(_ newText: NSAttributedString) {
        updateUpdateCurrentLabel(newText: newText)
    }
}

private extension NSMutableAttributedString {

    var fullRange: NSRange {
        NSRange(location: 0, length: length)
    }
    func addAttributes(attributes: [NSAttributedString.Key : Any]) {
        addAttributes(attributes, range: fullRange)
    }

    func addAttribute(_ key: NSAttributedString.Key, value: Any) {
        addAttribute(key, value: value, range: fullRange)
    }
}
