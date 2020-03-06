//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/17/19.
//

import Foundation
import UIKit

public protocol CollectionViewCellReusableUIItem: AnyReusableUIItem {
    func setupCell(from collectionView: UICollectionView, at indexPath: IndexPath)  -> UICollectionViewCell
}

public protocol CollectionViewSupplimentaryUIItem: AnyReusableUIItem {
    func setupView(from collectionView: UICollectionView, at indexPath: IndexPath)  -> UICollectionReusableView?
}

public protocol CollectionViewSection {
    var rows: [CollectionViewCellReusableUIItem] { get }
    var header: CollectionViewSupplimentaryUIItem? { get }
    var footer: CollectionViewSupplimentaryUIItem? { get }
    var supplimentaryViews: [CollectionViewSupplimentaryUIItem] { get }
}

extension CollectionViewSection {
    var allItems: [AnyReusableUIItem] { [header, footer].compactMap{$0} + rows + supplimentaryViews }
}

public protocol TypedCollectionViewData {
    var sections: [CollectionViewSection] { get }
    init()
}

open class GenericCollectionViewController<Data: TypedCollectionViewData>: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    public var data: Data = Data() {
        didSet {
            updateViewsToRegister()
            collectionView.reloadData()
        }
    }

    private var viewsToRegister: [ReusableItemInfo] = [] {
        didSet {
            let oldIdentifiers: Set<String> = Set(oldValue.map{$0.reuseIdentifier})
            let newViews = viewsToRegister.filter{ !oldIdentifiers.contains($0.reuseIdentifier) }
            if !newViews.isEmpty {
                newViews.forEach(collectionView.register)
            }
        }
    }

    private var sections: [CollectionViewSection] { data.sections }

    open override func viewDidLoad() {
        super.viewDidLoad()
        registerAllViews()
    }

    func updateViewsToRegister() {
        let allItems = sections.flatMap{$0.allItems}.map{$0.viewInfo}
        var uniqueItems: [ReusableItemInfo] = []
        allItems.forEach { item in
            guard !uniqueItems.contains(where: {existing in !existing.equalInfo(to: item) }) else {
                return
            }
            uniqueItems.append(item)
        }

        viewsToRegister = uniqueItems
    }

    func registerAllViews() {
        updateViewsToRegister()
        viewsToRegister.forEach(collectionView.register)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        sections[section].header?.viewInfo.size.cellSize ?? CGSize.zero
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sections[indexPath.section].rows[indexPath.row].viewInfo.size.cellSize
        var test = 1
        test += 4 + 5
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        sections[section].footer?.viewInfo.size.cellSize ?? CGSize.zero
    }

    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return section.header?.setupView(from: collectionView, at: indexPath) ?? UICollectionReusableView()
        case UICollectionView.elementKindSectionFooter:
            return section.footer?.setupView(from: collectionView, at: indexPath) ?? UICollectionReusableView()
        default:
            return section.supplimentaryViews
                .first { kind == $0.viewInfo.kind.collectionViewKind }?
                .setupView(from: collectionView, at: indexPath) ?? UICollectionReusableView()
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        sections[indexPath.section].rows[indexPath.row].setupCell(from: collectionView, at: indexPath)
    }
}


