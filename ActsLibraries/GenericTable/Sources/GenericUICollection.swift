//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/28/19.
//

import Foundation
import UIKit

public enum CollectionUIReusableType: Equatable {
    case header, footer, cell, other(kind: String)

    var collectionViewKind: String {
        switch self {
        case .cell: return ""
        case .header: return UICollectionView.elementKindSectionHeader
        case .footer: return UICollectionView.elementKindSectionFooter
        case .other(let kind): return kind
        }
    }
}

public enum ReusableItemSize {
    case automatic
    case constant(CGSize)

    var tableRowHeight: CGFloat {
        switch self {
        case .automatic: return UITableView.automaticDimension
        case .constant(let size): return size.height
        }
    }

    var cellSize: CGSize {
        switch self {
        case .automatic: return UICollectionViewFlowLayout.automaticSize
        case .constant(let size): return size
        }
    }
}
public protocol AnyReusableUIItem {
    var viewInfo: ReusableItemInfo { get }
}
