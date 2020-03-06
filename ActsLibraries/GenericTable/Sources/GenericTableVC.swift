//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/17/19.
//

import Foundation
import UIKit

public protocol TableViewCellReusableUIItem: AnyReusableUIItem {
    func setupCell(from tableView: UITableView, at indexPath: IndexPath)  -> UITableViewCell
}

public protocol TableViewHeaderFooterUIItem: AnyReusableUIItem {
    func setupView(from tableView: UITableView)  -> UIView?
}

public protocol TableViewSection {
    var rows: [TableViewCellReusableUIItem] { get }
    var header: TableViewHeaderFooterUIItem? { get }
    var footer: TableViewHeaderFooterUIItem? { get }
}

extension TableViewSection {
    var allItems: [AnyReusableUIItem] { [header, footer].compactMap{$0} + rows }
}

public protocol TypedTableViewData {
    var sections: [TableViewSection] { get }
    init()
}

open class GenericTableViewController<Data: TypedTableViewData>: UITableViewController {

    private var viewsToRegister: [ReusableItemInfo] = [] {
        didSet {
            let oldIdentifiers: Set<String> = Set(oldValue.map{$0.reuseIdentifier})
            let newViews = viewsToRegister.filter{ !oldIdentifiers.contains($0.reuseIdentifier) }
            if !newViews.isEmpty {
                newViews.forEach(tableView.register)
                updateHeights()
            }
        }
    }

    public var data: Data = Data() {
        didSet {
            dataChanged()
        }
    }

    public func dataChanged() {
        updateViewsToRegister()
        tableView.reloadData()
    }

    private var sections: [TableViewSection] { data.sections }

    func updateViewsToRegister() {
        let allItems = sections.flatMap{$0.allItems}.map{$0.viewInfo}
        var uniqueItems: [ReusableItemInfo] = []
        allItems.forEach { item in
            let itemIsNotInUniqueItems = !uniqueItems.contains(where: {existing in existing.equalInfo(to: item) })
            if itemIsNotInUniqueItems {
                uniqueItems.append(item)
            }
        }

        viewsToRegister = uniqueItems
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        registerAllViews()
        updateHeights()
    }

    func registerAllViews() {
        updateViewsToRegister()
        viewsToRegister.forEach(tableView.register)
    }

    func updateHeights() {
        let headerHeight = sections.first {$0.header != nil}?.header?.viewInfo.size.tableRowHeight
        let footerHeight = sections.first {$0.header != nil}?.footer?.viewInfo.size.tableRowHeight
        tableView.estimatedSectionHeaderHeight = headerHeight ?? 0
        tableView.estimatedRowHeight = ReusableItemSize.automatic.tableRowHeight
        tableView.estimatedSectionFooterHeight = footerHeight ?? 0
    }

    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (sections[section].header?.viewInfo.size ?? .automatic).tableRowHeight
    }

    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        sections[indexPath.section].rows[indexPath.row].viewInfo.size.tableRowHeight
    }

    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        (sections[section].footer?.viewInfo.size ?? .automatic).tableRowHeight
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sections[section].header?.setupView(from: tableView)
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        sections[indexPath.section].rows[indexPath.row].setupCell(from: tableView, at: indexPath)
    }

    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        sections[section].footer?.setupView(from: tableView)
    }
}


