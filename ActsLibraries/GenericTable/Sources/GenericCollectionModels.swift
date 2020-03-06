//
//  GenericCollectionModels.swift
//  ActsLibrariesPackageDescription
//
//  Created by Paul Fechner on 10/23/19.
//

import Foundation
import UIKit

public struct GenericCollectionCell<ViewType: ModelUpdatable>: CollectionViewCellReusableUIItem, UIUpdatingItem where ViewType: UICollectionViewCell {

    public typealias View = ViewType
    public let model: View.Model
    public let viewInfo: ReusableItemInfo

    public init(model: View.Model, viewInfo: ReusableItemInfo) {
        self.model = model
        self.viewInfo = viewInfo
    }
}

//public protocol ModelConvertable {
//    associatedtype TargetType
//    var converted: TargetType { get }
//}

public struct GenericCollectionSection<CellModel: ModelConvertable, CellViewType: ModelUpdatable & ViewInfoable>: CollectionViewSection where CellViewType.Model == CellModel.TargetType, CellViewType: UICollectionViewCell  {

    public var rows: [CollectionViewCellReusableUIItem]
    public let header: CollectionViewSupplimentaryUIItem?
    public let footer: CollectionViewSupplimentaryUIItem?
    public let supplimentaryViews: [CollectionViewSupplimentaryUIItem]

    public init(rows: [GenericCollectionCell<CellViewType>], header: CollectionViewSupplimentaryUIItem? = nil, footer: CollectionViewSupplimentaryUIItem? = nil, supplimentaryViews: [CollectionViewSupplimentaryUIItem] = []) {
        self.rows = rows
        self.header = header
        self.footer = footer
        self.supplimentaryViews = supplimentaryViews
    }

    public init(rowModels: [CellModel], header: CollectionViewSupplimentaryUIItem? = nil, footer: CollectionViewSupplimentaryUIItem? = nil, supplimentaryViews: [CollectionViewSupplimentaryUIItem] = []) {
        self.rows = rowModels.map{GenericCollectionCell<CellViewType>(model: $0.converted, viewInfo: CellViewType.viewInfo)}
        self.header = header
        self.footer = footer
        self.supplimentaryViews = supplimentaryViews
    }
}
