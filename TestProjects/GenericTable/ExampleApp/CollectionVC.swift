//
//  ViewController.swift
//  ExampleApp
//
//  Created by Paul Fechner on 10/21/19.
//  Copyright © 2019 ActsMedia. All rights reserved.
//

import UIKit
import GenericTable

struct MyCollectionData: TypedCollectionViewData {
    var sections: [CollectionViewSection] = []
}

class CollectionVC: GenericCollectionViewController<MyCollectionData> {
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
        data = MyCollectionData(sections: [GenericCollectionSection<OutsideModel, MyCollectionCell>(rowModels: models)])
    }

}

