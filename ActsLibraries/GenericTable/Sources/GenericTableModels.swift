//
//  GenericTableModels.swift
//  ActsLibrariesPackageDescription
//
//  Created by Paul Fechner on 10/23/19.
//

import Foundation
import UIKit

public struct GenericTableCell<ViewType: ModelUpdatable>: TableViewCellReusableUIItem, UIUpdatingItem where ViewType: UITableViewCell {
    public typealias View = ViewType
    public let model: View.Model
    public let viewInfo: ReusableItemInfo

    public init(model: View.Model, viewInfo: ReusableItemInfo) {
        self.model = model
        self.viewInfo = viewInfo
    }
}

public protocol ModelConvertable {
    associatedtype TargetType
    var converted: TargetType { get }
}

public struct GenericSection<RowModel: ModelConvertable, RowViewType: ModelUpdatable & ViewInfoable>: TableViewSection where RowViewType.Model == RowModel.TargetType, RowViewType: UITableViewCell  {


    public var rows: [TableViewCellReusableUIItem]
    public let header: TableViewHeaderFooterUIItem?
    public let footer: TableViewHeaderFooterUIItem?

    public init(rows: [GenericTableCell<RowViewType>], header: TableViewHeaderFooterUIItem? = nil, footer: TableViewHeaderFooterUIItem? = nil) {
        self.rows = rows
        self.header = header
        self.footer = footer
    }

    public init(rowModels: [RowModel], header: TableViewHeaderFooterUIItem? = nil, footer: TableViewHeaderFooterUIItem? = nil) {
        self.rows = rowModels.map{GenericTableCell<RowViewType>(model: $0.converted, viewInfo: RowViewType.viewInfo)}
        self.header = header
        self.footer = footer
    }
}
