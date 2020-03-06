//
//  MyCellTableViewCell.swift
//  ExampleApp
//
//  Created by Paul Fechner on 10/21/19.
//  Copyright © 2019 ActsMedia. All rights reserved.
//

import UIKit
import GenericTable

struct TitleCellModel {
    let title: String
}
class MyCell: UITableViewCell, ModelUpdatable {



    static let viewInfo: ReusableItemInfo = ReusableItemInfo(reuseIdentifier: "MyCell",
                                                             registrationType: .nib({UINib(nibName: "MyCell", bundle: nil)}),
                                                             kind: .cell)

    @IBOutlet
    weak var customLabel: UILabel!


    func update(with model: TitleCellModel) {
        customLabel.text = model.title
    }
}
