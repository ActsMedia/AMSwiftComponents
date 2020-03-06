//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/12/20.
//

@testable import ResourceManager
import Foundation
import Quick
import Nimble

class ProgressDownloaderTests: QuickSpec {


    //Increments with each call
    let testFileNumber: () -> Int = {
        var number = 0
        return {
            number += 1
            return number
        }
    }()

    let remoteFileURL = URL(string: "https://file-examples.com/wp-content/uploads/2017/10/file-sample_150kB.pdf")!

    func makeEndingFileName() -> String {
        return "NewFile\(testFileNumber()).pdf"
    }

    override func spec() {

        describe("DownloadOperation") {
            let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            context("Downloading") {
                it("Copies") {
                    var error: Error?
                    let endingURL: URL = documentsURL.appendingPathComponent(self.makeEndingFileName()).standardizedFileURL

                    let operation = FileDownloadOperation(remoteURL: self.remoteFileURL, destinationURL: endingURL, copyPolicy: .alwaysCopy, errorAction: {
                        error = $0
                        print($0)
                    }) { (url, ratio) in
                        print("\(url) at ratio: \(ratio)")
                    }
                    let queue = OperationQueue()
                    queue.addOperations([operation], waitUntilFinished: true)
                    expect(error).to(beNil())
                    expect(FileManager.default.fileExists(at: endingURL)) == true
                    let newFileData = try? Data(contentsOf: endingURL)
                    expect(newFileData).toNot(beNil())
                }
            }

//            context("CopyingToNewFolder") {
//                it("Copies") {
//                    let endingURL: URL = documentsURL.appendingPathComponent("newFolder/\(self.makeEndingFileName())").standardizedFileURL
//
//                    let operation = CopyOperation(startingURL: startingURL, endingURL: endingURL, copyPolicy: .alwaysCopy, debugMode: true) {
//                        print($0)
//                    }
//                    let queue = OperationQueue()
//                    queue.addOperations([operation], waitUntilFinished: true)
//
//                    expect(FileManager.default.fileExists(at: endingURL)) == true
//                    let newFileText = try? String(contentsOf: endingURL, encoding: .utf8)
//                    expect(newFileText).toNot(beNil())
//                    expect(newFileText) == self.testFileText
//                }
//            }
        }
    }
}

