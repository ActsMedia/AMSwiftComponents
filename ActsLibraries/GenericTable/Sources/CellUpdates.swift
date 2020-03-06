//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/28/19.
//

import Foundation
import UIKit

public protocol ModelUpdatable {
    associatedtype Model
    func update(with model: Model)
}

public protocol ViewInfoable {
    static var viewInfo: ReusableItemInfo { get }
}

public protocol UIUpdatingItem {
    associatedtype View: ModelUpdatable
    var model: View.Model { get }
}


extension TableViewCellReusableUIItem where Self: UIUpdatingItem, View: UITableViewCell {
    public func setupCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewInfo.reuseIdentifier, for: indexPath)
        guard let typedCell = cell as? View else {
            return UITableViewCell()
        }
        typedCell.update(with: model)
        return typedCell
    }
}

extension TableViewHeaderFooterUIItem where Self: UIUpdatingItem, View: UITableViewHeaderFooterView {
    public func setupView(from tableView: UITableView) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewInfo.reuseIdentifier)
        guard let typedView = view as? View else {
            return nil
        }

        typedView.update(with: model)
        return typedView
    }
}

extension CollectionViewCellReusableUIItem where Self: UIUpdatingItem, View: UICollectionViewCell {
    public func setupCell(from collectionView: UICollectionView, at indexPath: IndexPath)  -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewInfo.reuseIdentifier, for: indexPath)
        guard let typedCell = cell as? View else {
            return UICollectionViewCell()
        }
        typedCell.update(with: model)
        return typedCell
    }
}

extension CollectionViewSupplimentaryUIItem where Self: UIUpdatingItem, View: UICollectionReusableView {
    public func setupView(from collectionView: UICollectionView, at indexPath: IndexPath)  -> UICollectionReusableView? {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: viewInfo.kind.collectionViewKind, withReuseIdentifier: viewInfo.reuseIdentifier, for: indexPath)
        guard let typedView = view as? View else {
            return UICollectionReusableView()
        }

        typedView.update(with: model)
        return typedView
    }
}
