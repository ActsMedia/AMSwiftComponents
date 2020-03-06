//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/13/20.
//

@testable import ResourceManager
import Foundation
import Quick
import Nimble


class CodableComparisonFactoryTests: QuickSpec {

    override func spec() {
        describe("CodableComparisonFactory") {
            let comparison = CodableComparisonFactory<JSONDecoder, TestType>(decoder: JSONDecoder()) {
                $0.comparableProperty < $1.comparableProperty
            }
            context("WithLeftSmaller") {
                it("ReturnsTrue") {
                    expect(comparison.compare(firstTestJSONData, secondTestJSONData)) == true
                }
            }
            context("WithRightSmaller") {
                it("ReturnsFalse") {
                    expect(comparison.compare(secondTestJSONData, firstTestJSONData)) == false
                }
            }
        }
    }
}

struct TestType: Codable {
    let comparableProperty: Int
}

private let firstTestJSONData = try! JSONEncoder().encode(TestType(comparableProperty: 1))
private let secondTestJSONData = try! JSONEncoder().encode(TestType(comparableProperty: 2))
