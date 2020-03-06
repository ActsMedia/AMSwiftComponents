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

class CopyOperationTests: QuickSpec {


    //Increments with each call
    let testFileNumber: () -> Int = {
        var number = 0
        return {
            number += 1
            return number
        }
    }()

    func makeTestFileName() -> String {
        return "MyFile\(testFileNumber()).txt"
    }
    func makeEndingFileName() -> String {
        return "NewFile\(testFileNumber()).txt"
    }

    let testFileText = "Some Test File Text"


    override func spec() {

        describe("CopyOperation") {
            let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var startingURL: URL!

            beforeEach {
                startingURL = documentsURL.appendingPathComponent(self.makeTestFileName()).standardizedFileURL
                _ = FileManager.default.createFile(atPath: startingURL.path, contents: nil, attributes: nil)
                try! self.testFileText.write(to: startingURL, atomically: true, encoding: .utf8)
            }

            context("CopyingToSameFolder") {
                it("Copies") {
                    let endingURL: URL = documentsURL.appendingPathComponent(self.makeEndingFileName()).standardizedFileURL

                    let operation = FileCopyOperation(startingURL: startingURL, destinationURL: endingURL, copyPolicy: .alwaysCopy) {
                        print($0)
                    }
                    let queue = OperationQueue()
                    queue.addOperations([operation], waitUntilFinished: true)

                    expect(FileManager.default.fileExists(at: endingURL)) == true
                    let newFileText = try? String(contentsOf: endingURL, encoding: .utf8)
                    expect(newFileText).toNot(beNil())
                    expect(newFileText) == self.testFileText
                }
            }

            context("CopyingToNewFolder") {
                it("Copies") {
                    let destinationURL: URL = documentsURL.appendingPathComponent("newFolder/\(self.makeEndingFileName())").standardizedFileURL

                    let operation = FileCopyOperation(startingURL: startingURL, destinationURL: destinationURL, copyPolicy: .alwaysCopy) {
                        print($0)
                    }
                    let queue = OperationQueue()
                    queue.addOperations([operation], waitUntilFinished: true)

                    expect(FileManager.default.fileExists(at: destinationURL)) == true
                    let newFileText = try? String(contentsOf: destinationURL, encoding: .utf8)
                    expect(newFileText).toNot(beNil())
                    expect(newFileText) == self.testFileText
                }
            }
        }
    }
}
