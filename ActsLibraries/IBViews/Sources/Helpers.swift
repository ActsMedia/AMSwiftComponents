//
//  File.swift
//  
//
//  Created by Paul Fechner on 11/4/19.
//

import Foundation
#if canImport(UIKit)

import UIKit

extension CACornerMask {
    func adding(corner: CACornerMask, if boolean: Bool) -> CACornerMask {
        if boolean {
            return union(corner)
        }
        else {
            return self
        }
    }
}

extension UIRectCorner {
    func adding(corner: UIRectCorner, if boolean: Bool) -> UIRectCorner {
        if boolean {
            return union(corner)
        }
        else {
            return self
        }
    }
}


#endif
