//
//  EZTextShareable.swift
//  
//
//  Created by Paul Fechner on 4/17/20.
//

import Foundation

public struct EZTextShareable: EZShareable {

    public struct SharingText {
        public static let empty = SharingText(plainText: "", htmlText: "")
        public let plainText: String
        public let htmlText: String
        public init(plainText: String, htmlText: String) {
            self.plainText = plainText
            self.htmlText = htmlText
        }

        public init(_ plainText: String, _ htmlText: String) {
            self.plainText = plainText
            self.htmlText = htmlText
        }
    }

    public let subject: String

    public let preItemsText: SharingText
    public let items: [SharingText]
    public let postItemsText: SharingText

    public let plainTextFormatter: (EZTextShareable) -> String
    public let htmlFormatter: (EZTextShareable) -> String

    public init(subject: String, preItemsText: SharingText, items: [SharingText], postItemsText: SharingText,
                plainTextFormatter: @escaping (EZTextShareable) -> String = Self.defaultPlainTextFormatter,
                htmlFormatter: @escaping (EZTextShareable) -> String = Self.defaultHTMLFormatter) {
        self.subject = subject
        self.preItemsText = preItemsText
        self.items = items
        self.postItemsText = postItemsText
        self.plainTextFormatter = plainTextFormatter
        self.htmlFormatter = htmlFormatter
    }

    public var shareItem: EZShareItem {
        let plainText = plainTextFormatter(self)
        return EZShareData(shareType: .text(htmlText: htmlFormatter(self)), text: plainText, subject: subject, placeholderText: plainText)
    }

    public static var defaultPlainTextFormatter: (EZTextShareable) -> String = {
        var text = $0.preItemsText.plainText.isEmpty ? "" : "\($0.preItemsText.plainText)\n"
        text += "\($0.items.reduce("\n", {$0 + "\($1.plainText)"}))"
        text += !$0.postItemsText.plainText.isEmpty ? "" : "\n\($0.postItemsText.plainText)"
        return text
    }

    public static var defaultHTMLFormatter: (EZTextShareable) -> String = {

        var text = $0.preItemsText.htmlText.isEmpty ? "" : "\($0.preItemsText.htmlText)\n<br/>"
        text += "\($0.items.reduce("\n<br/>\n", {$0 + "\($1.htmlText)\n<br/>\n"}))"
        text += !$0.postItemsText.htmlText.isEmpty ? "" : "\n<br/>\n\($0.postItemsText.htmlText)"
        return text
    }
}
