//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/31/19.
//

@testable import UIWrappers
import Foundation
import Quick
import Nimble
import UIKit

class PartialImplementationTests: QuickSpec {
    override func spec() {
        describe("UIColorHex") {
            describe("CUnsignedLongLong.asHexFloat") {
                it("GetCorrectValues") {
                    expect(CUnsignedLongLong(0).asHexFloat) ≈ 0.0
                    expect(CUnsignedLongLong(128).asHexFloat) ≈ 0.5 ± 0.01
                    expect(CUnsignedLongLong(64).asHexFloat) ≈ 0.25 ± 0.001
                    expect(CUnsignedLongLong(255).asHexFloat) ≈ 1.0
                    expect(CUnsignedLongLong(256).asHexFloat) ≈ 1.0
                    expect(CUnsignedLongLong(1000).asHexFloat) ≈ 1.0
                }
            }
            describe("String.hex64BitValue") {
                it("GetsCorrectValues") {
                    expect("ff".hex64BitValue) == 255
                    expect("00".hex64BitValue) == 0
                    expect("01".hex64BitValue) == 1
                    expect("0f".hex64BitValue) == 15
                    expect("80".hex64BitValue) == 128
                    expect("-50".hex64BitValue) == 0
                    expect("laiuwenr".hex64BitValue) == 0
                }
            }
            describe("String.isAlphaHex") {
                it("GetsCorrectValues") {
                    expect("ffffff".isAlphaHex) == false
                    expect("fff".isAlphaHex) == false
                    expect("ffffffff".isAlphaHex) == true
                    expect("ffff".isAlphaHex) == true
                }
                it("handlesBothCases") {
                    expect("ffff".isAlphaHex) == true
                    expect("FFFF".isAlphaHex) == true
                }
            }
            describe("String.hexLength") {
                it("GetValueWhenValid") {
                    expect("ffffff".hexLength) == 2
                    expect("fff".hexLength) == 1
                    expect("ffffffff".hexLength) == 2
                    expect("ffff".hexLength) == 1
                }
                it("handlesBothCases") {
                    expect("ffffff".hexLength) == 2
                    expect("FFFFFF".hexLength) == 2
                    expect("fff".hexLength) == 1
                    expect("FFF".hexLength) == 1
                }
                it("FailsWhenInvalid") {
                    expect("ff".hexLength).to(beNil())
                    expect("fffff".hexLength).to(beNil())
                    expect("fffffff".hexLength).to(beNil())
                    expect("fffffffff".hexLength).to(beNil())
                    expect("f".hexLength).to(beNil())
                    expect("".hexLength).to(beNil())
                }
            }
            describe("UIColor.init(hex)") {
                it("ConvertsActurately") {
                    let white = UIColor(hex: "40ff8000")
                    let whiteRGBA = white.rgba
                    expect(whiteRGBA.red) ≈ 1
                    expect(whiteRGBA.green) ≈ 0.5 ± 0.01
                    expect(whiteRGBA.blue) ≈ 0
                    expect(whiteRGBA.alpha) ≈ 0.25 ± 0.001
                }
                it("HandlesInputIdentically") {
                    expect(UIColor(hex: "a").rgba == UIColor(hex: "aaa").rgba) == true
                    expect(UIColor(hex: "a").rgba == UIColor(hex: "faaa").rgba) == true
                    expect(UIColor(hex: "a").rgba == UIColor(hex: "aaaaaa").rgba) == true
                    expect(UIColor(hex: "a").rgba == UIColor(hex: "ffaaaaaa").rgba) == true
                    expect(UIColor(hex: "aaaa").rgba == UIColor(hex: "aaaaaaaa").rgba) == true
                }
                it("Ignores#") {
                    expect(UIColor(hex: "#0")) != UIColor.white
                    expect(UIColor(hex: "#0").rgba == (0, 0, 0, 1)) == true
                    expect(UIColor(hex: "#000").rgba == (0, 0, 0, 1)) == true
                    expect(UIColor(hex: "#0000").rgba == (0, 0, 0, 0)) == true
                    expect(UIColor(hex: "#000000").rgba == (0, 0, 0, 1)) == true
                    expect(UIColor(hex: "#00000000").rgba == (0, 0, 0, 0)) == true
                }
            }
        }
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
