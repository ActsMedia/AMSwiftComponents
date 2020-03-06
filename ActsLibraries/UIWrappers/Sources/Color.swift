//
//  File.swift
//  
//
//  Created by Paul Fechner on 10/31/19.
//

import Foundation
import UIKit

public enum ColorType: Equatable {
    case color(UIColor)
    case resource(String)
    case hex(String)

    public var color: UIColor {
        switch self {
        case .color(let color): return color
        case .resource(let name): return UIColor(named: name) ?? .white
        case .hex(let hex): return UIColor(hex: hex)
        }
    }
}

extension CharacterSet {
    static var hexCharacters: CharacterSet {
        CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    }
}
extension UIColor {

    public convenience init(hex: String) {
        guard let hexString = hex.hexableString else {
            assertionFailure("UIColor(hex: String) called with invalid hex: \(hex)")
            self.init(cgColor: UIColor.white.cgColor)
            return
        }
        let hexLength = 2

        let secondValueStartIndex = hexString.index(hexString.startIndex, offsetBy: hexLength)
        let thirdValueStartIndex = hexString.index(secondValueStartIndex, offsetBy: hexLength)
        let fourthValueStartIndex = hexString.index(thirdValueStartIndex, offsetBy: hexLength)

        let aValue = String(hexString[..<secondValueStartIndex])
        let rValue = String(hexString[secondValueStartIndex..<thirdValueStartIndex])
        let gValue = String(hexString[thirdValueStartIndex..<fourthValueStartIndex])
        let bValue = String(hexString[fourthValueStartIndex...])

        self.init(rHex: rValue, gHex: gValue, bHex: bValue, aHex: aValue)
    }
    public convenience init(rHex: String, gHex: String, bHex: String, aHex: String? = nil) {
        self.init (red: rHex.hex64BitValue.asHexFloat,
                   green: gHex.hex64BitValue.asHexFloat,
                   blue: bHex.hex64BitValue.asHexFloat,
                   alpha: aHex?.hex64BitValue.asHexFloat ?? 1.0)
    }
}

extension String {

    var hexableString: String? {
        let hexString = String(self.unicodeScalars.filter(CharacterSet.hexCharacters.contains))
        switch hexString.count {
        case 1: return "FF\(String(repeating: hexString[startIndex], count: 6))"
        case 3: return self.reduce("FF") { (current: String, next) in "\(current)\(next.doubled)" }
        case 4: return self.reduce("") { (current: String, next) in "\(current)\(next.doubled)" }
        case 6: return "FF\(hexString)"
        case 8: return hexString
        default: return nil
        }
    }

    var hexLength: Int? {
        switch count {
        case 3, 4: return 1
        case 6, 8: return 2
        default: return nil
        }
    }

    var isAlphaHex: Bool { count == 4 || count == 8 }

    var hex64BitValue: CUnsignedLongLong {
        var value: CUnsignedLongLong = 0
        Scanner(string: self).scanHexInt64(&value)
        return value
    }
}

extension Character {
    var doubled: String { "\(self)\(self)"}
}

extension CUnsignedLongLong {
    var asHexFloat: CGFloat {
        let value = CGFloat(self) / 255
        return value > 1.0 ? 1.0 : value < 0.0 ? 0.0 : value
    }
}
