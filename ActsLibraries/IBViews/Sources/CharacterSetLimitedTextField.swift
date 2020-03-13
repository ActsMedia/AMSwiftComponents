//
//  File.swift
//  
//
//  Created by Paul Fechner on 3/4/20.
//

import UIKit

open class CharacterSetLimitedTextField: UITextField, UITextFieldDelegate {
    
    private static var defaultCharacterSet: CharacterSet { .alphanumerics }
    public var allowedCharacterSet: CharacterSet = CharacterSetLimitedTextField.defaultCharacterSet {
        didSet {
            if allowedCharacterSet != oldValue {
                invertedAllowedCharacterSet = allowedCharacterSet.inverted
                characterSetChanged()
            }
        }
    }

    /// Should always be the inverse of allowedCharacterSet. Using because this is usually what's being used.
    private var invertedAllowedCharacterSet: CharacterSet = CharacterSetLimitedTextField.defaultCharacterSet.inverted

    private var realDelegate: UITextFieldDelegate?

    // Keep track of the text field's real delegate
    override open var delegate: UITextFieldDelegate? {
        get {
            return realDelegate
        }
        set {
            realDelegate = newValue
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        // Make the text field its own delegate
        super.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Make the text field its own delegate
        super.delegate = self
    }

    // This is one third of the magic
    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let realDelegate = realDelegate, realDelegate.responds(to: aSelector) {
            return realDelegate
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }

    // This is another third of the magic
    override public func responds(to aSelector: Selector!) -> Bool {
        if let realDelegate = realDelegate, realDelegate.responds(to: aSelector) {
            return true
        } else {
            return super.responds(to: aSelector)
        }
    }

    private func characterSetChanged() {
        self.text = self.text?.trimmingCharacters(in: invertedAllowedCharacterSet)
    }

    override open func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        // it's probably "delete"
        guard !text.isEmpty && !text.isNewline else { return true }

        let trimmedText = text.trimmingCharacters(in: invertedAllowedCharacterSet)

        // Text doesn't include any illegal characters
        if trimmedText == text {
            return true
        }
        // Text included no valid characters
        else if trimmedText.isEmpty {
            return false
        }
        // Otherwise, (probably from a paste) we need to strip the illegal characters and update the text.
        else {
            if let currentText = self.text {
                let startIndex = currentText.index(currentText.startIndex, offsetBy: offset(from: beginningOfDocument, to: range.start))
                let endOffset = offset(from: beginningOfDocument, to: range.end)

                let endIndex = currentText.index(startIndex, offsetBy: endOffset, limitedBy: currentText.endIndex) ?? currentText.endIndex
                let newString = currentText.replacingCharacters(in: startIndex..<endIndex, with: trimmedText)
                self.text = newString
                return true
            }
            else {
                self.text = trimmedText
            }
            return false
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let realDelegateCall = realDelegate?.textField(_:shouldChangeCharactersIn:replacementString:) {
            return realDelegateCall(textField, range, string)
        }
        else if let startPosition = self.position(from: beginningOfDocument, offset: range.lowerBound),
            let endPosition = self.position(from: beginningOfDocument, offset: range.upperBound),
            let range = self.textRange(from: startPosition, to: endPosition) {

            return self.shouldChangeText(in: range, replacementText: string)
        }
        else {
            return true
        }
    }
}

private extension String {
    var isNewline: Bool {
        count == 1 && first?.isNewline ?? false
    }
}
