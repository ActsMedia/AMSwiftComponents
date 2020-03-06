//
//  TitleAndImageUIItem.swift
//  MMMEIS
//
//  Created by Paul Fechner on 10/30/19.
//  Copyright © 2019 ActsMedia. All rights reserved.
//

import UIKit
import SwiftyIB

//extension ModelConvertable where Self == TargetType {
//    var converted: TargetType { self }
//}

public typealias TitleAndImageCellSection<Cell: TitleAndImageTableCell> =
    GenericSection<TitleAndImageTableCell.Model, Cell> where Cell: ViewInfoable

open class TitleAndImageTableCell: UITableViewCell, ModelUpdatable {

    public struct Model: ModelConvertable {
        let title: String
        let image: UIImage
        public var converted: Model { self }

        public init(title: String, image: UIImage) {
            self.title = title
            self.image = image
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!

    public func update(with model: Model) {
        titleLabel.text = model.title
        mainImageView.image = model.image
    }
}
