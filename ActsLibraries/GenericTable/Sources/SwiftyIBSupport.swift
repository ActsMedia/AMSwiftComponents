//
//  File.swift
//  
//
//  Created by Paul Fechner on 11/1/19.
//

#if canImport(SwiftyIB)
#if canImport(UIKit)
import SwiftyIB
import UIKit

extension IBNibIdentifiable where Self: IBNibReusable, Self: UITableViewCell {
    static public func reusableItemInfo(with size: ReusableItemSize = .automatic, in bundle: Bundle? = nil) -> ReusableItemInfo {
        ReusableItemInfo(reuseIdentifier: reuseIBIdentifier.name,
                         registrationType: CollectionUIItemRegistrationType.nib({UINib.make(with: nibIdentifier, in: bundle)!}),
                         kind: .cell, size: size)
    }
}

extension IBNibIdentifiable where Self: IBNibReusable, Self: UITableViewHeaderFooterView {
    static public func reusableItemInfo(with size: ReusableItemSize = .automatic, in bundle: Bundle? = nil) -> ReusableItemInfo {
        ReusableItemInfo(reuseIdentifier: reuseIBIdentifier.name,
                         registrationType: CollectionUIItemRegistrationType.nib({UINib.make(with: nibIdentifier, in: bundle)!}),
                         kind: .header, size: size)
    }
}

extension IBNibIdentifiable where Self: IBNibReusable, Self: UICollectionViewCell {
    static public func reusableItemInfo(with size: ReusableItemSize = .automatic, in bundle: Bundle? = nil) -> ReusableItemInfo {
        ReusableItemInfo(reuseIdentifier: reuseIBIdentifier.name,
                         registrationType: CollectionUIItemRegistrationType.nib({UINib.make(with: nibIdentifier, in: bundle)!}),
                         kind: .cell, size: size)
    }
}

extension IBNibIdentifiable where Self: IBNibReusable, Self: UICollectionReusableView {
    static public func reusableItemInfo(ofType type: CollectionUIReusableType, with size: ReusableItemSize = .automatic, in bundle: Bundle? = nil) -> ReusableItemInfo {
        ReusableItemInfo(reuseIdentifier: reuseIBIdentifier.name,
                         registrationType: CollectionUIItemRegistrationType.nib({UINib.make(with: nibIdentifier, in: bundle)!}),
                         kind: type, size: size)
    }
}

#endif
#endif
