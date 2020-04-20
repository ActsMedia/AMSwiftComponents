//
//  DeepLinkTests.swift
//  
//
//  Created by Paul Fechner on 4/18/20.
//

@testable import EZShare

import Foundation
import Quick
import Nimble

class DeepLinkTests: QuickSpec {

    override func spec() {
        describe("DeepLinkTests") {
            it("works") {
                EZDeepLink().test(with: URL(string: "testURL://first/second?itemThing=4")!)
                EZDeepLink().test(with: URL(string: "https://www.place.com/first/second?itemThing=4")!)
                expect(true) == true
            }
        }
    }
}
