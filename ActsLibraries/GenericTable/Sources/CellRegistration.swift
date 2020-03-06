//
//  CellRegistration.swift
//  ActsLibrariesPackageDescription
//
//  Created by Paul Fechner on 10/28/19.
//

import Foundation
import UIKit

public enum CollectionUIItemRegistrationType {
    case `class`(AnyClass)
    case nib(() -> UINib)
}

public struct ReusableItemInfo {
    public let reuseIdentifier: String
    public let registrationType: CollectionUIItemRegistrationType
    public let kind: CollectionUIReusableType
    public let size: ReusableItemSize

    func equalInfo(to other: ReusableItemInfo) -> Bool {
        return reuseIdentifier == other.reuseIdentifier && kind == other.kind
    }

    public init(reuseIdentifier: String, registrationType: CollectionUIItemRegistrationType,
                kind: CollectionUIReusableType, size: ReusableItemSize = .automatic) {
        self.reuseIdentifier = reuseIdentifier
        self.registrationType = registrationType
        self.kind = kind
        self.size = size
    }
}

public extension UITableView {

    func register(item: ReusableItemInfo) {
        switch item.kind {
        case .cell: registerCell(item)
        case .header, .footer: registerHeaderFooter(item)
        case .other(kind: let kind):
            assertionFailure("Tried to add reusableItem: \(kind) to UITableView")
        }
    }
    func registerHeaderFooter(_ info: ReusableItemInfo) {
        switch info.registrationType {
        case .class(let itemClass):
            register(itemClass, forHeaderFooterViewReuseIdentifier: info.reuseIdentifier)
        case .nib(let nib):
            register(nib(), forHeaderFooterViewReuseIdentifier: info.reuseIdentifier)
        }
    }

    func registerCell(_ info: ReusableItemInfo) {
        switch info.registrationType {
        case .class(let itemClass):
            register(itemClass, forCellReuseIdentifier: info.reuseIdentifier)
        case .nib(let nib):
            register(nib(), forCellReuseIdentifier: info.reuseIdentifier)
        }
    }
}

public extension UICollectionView {

    func register(item: ReusableItemInfo) {
        switch item.kind {
        case .cell: registerCell(item)
        case .header: registerHeader(item)
        case .footer: registerFooter(item)
        case .other(kind: let kind):
            registerSupplimentaryView(item, ofKind: kind)
        }
    }
    func registerHeader(_ info: ReusableItemInfo) {
        switch info.registrationType {
        case .class(let itemClass):
            register(itemClass, forSupplementaryViewOfKind: Self.elementKindSectionHeader, withReuseIdentifier: info.reuseIdentifier)
        case .nib(let nib):
            register(nib(), forSupplementaryViewOfKind: Self.elementKindSectionHeader, withReuseIdentifier: info.reuseIdentifier)
        }
    }

    func registerFooter(_ info: ReusableItemInfo) {
        switch info.registrationType {
        case .class(let itemClass):
            register(itemClass, forSupplementaryViewOfKind: Self.elementKindSectionFooter, withReuseIdentifier: info.reuseIdentifier)
        case .nib(let nib):
            register(nib(), forSupplementaryViewOfKind: Self.elementKindSectionFooter, withReuseIdentifier: info.reuseIdentifier)
        }
    }

    func registerSupplimentaryView(_ info: ReusableItemInfo, ofKind kind: String) {
        switch info.registrationType {
        case .class(let itemClass):
            register(itemClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: info.reuseIdentifier)
        case .nib(let nib):
            register(nib(), forSupplementaryViewOfKind: kind, withReuseIdentifier: info.reuseIdentifier)
        }
    }

    

    func registerCell(_ info: ReusableItemInfo) {
        switch info.registrationType {
        case .class(let itemClass):
            register(itemClass, forCellWithReuseIdentifier: info.reuseIdentifier)
        case .nib(let nib):
            register(nib(), forCellWithReuseIdentifier: info.reuseIdentifier)
        }
    }
}
