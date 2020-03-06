//
//  TestingTableVC.swift
//  TestApp
//
//  Created by Paul Fechner on 2/3/20.
//  Copyright © 2020 ActsMedia. All rights reserved.
//

import UIKit
import MediaViewer
import UIWrappers

struct TestingModel: MediaViewerModel, Equatable {
    let type: MediaViewerType
}

class TestingTableVC: UITableViewController {

    var rows: [(String, TestingModel)] = testRows
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath)

        cell.textLabel?.text = rows[indexPath.row].0

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemModel = rows[indexPath.row].1
        let mediaViewer = MediaViewerVC<TestingModel>()
        mediaViewer.model = itemModel
        navigationController?.pushViewController(mediaViewer, animated: true)
    }
}

let testRows: [(String, TestingModel)] = [
    ("Web", TestingModel(type: .web(.webURL(URL(string:"https://duckduckgo.com")!)))),
    ("Video", TestingModel(type: .video(URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!))),
    ("PDF", TestingModel(type: .pdf(URL(string: "https://www.sample-videos.com/pdf/Sample-pdf-5mb.pdf")!))),
    ("Image", TestingModel(type: MediaViewerType.image(.url(URL(string: "https://www.sample-videos.com/img/Sample-jpg-image-1mb.jpg")!)))),
]
