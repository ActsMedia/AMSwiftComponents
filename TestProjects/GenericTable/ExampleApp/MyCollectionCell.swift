//
//  MyCollectionCell.swift
//  ExampleApp
//
//  Created by Paul Fechner on 10/29/19.
//  Copyright © 2019 ActsMedia. All rights reserved.
//

import UIKit
import GenericTable

class MyCollectionCell: UICollectionViewCell, ModelUpdatable {

    static let viewInfo: ReusableItemInfo = ReusableItemInfo(reuseIdentifier: "MyCollectionCell",
                                                             registrationType: .nib({UINib(nibName: "MyCollectionCell", bundle: nil)}),
                                                             kind: .cell,
                                                             size: .constant(CGSize(width: 50, height: 50)))

    @IBOutlet
    weak var customLabel: UILabel!


    func update(with model: TitleCellModel) {
        customLabel.text = model.title
    }
}
