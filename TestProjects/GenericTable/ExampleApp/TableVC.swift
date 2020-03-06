//
//  ViewController.swift
//  ExampleApp
//
//  Created by Paul Fechner on 10/21/19.
//  Copyright © 2019 ActsMedia. All rights reserved.
//

import UIKit
import GenericTable

struct OutsideModel: ModelConvertable {
    let outsideTitle: String
    var converted: TitleCellModel { TitleCellModel(title: outsideTitle) }
}

struct MyTableData: TypedTableViewData {
    var sections: [TableViewSection] = []
}

class TableVC: GenericTableViewController<MyTableData> {
    var models: [OutsideModel] = [] {
        didSet {
            dataWasUpdated()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        models = [OutsideModel(outsideTitle: "hi there"), OutsideModel(outsideTitle: "second")]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.models.append(OutsideModel(outsideTitle: "new"))
        }
    }

    func dataWasUpdated() {
        data = MyTableData(sections: [GenericSection<OutsideModel, MyCell>(rowModels: models)])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

