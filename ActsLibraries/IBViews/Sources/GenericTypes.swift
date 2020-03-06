//
//  File.swift
//  
//
//  Created by Paul Fechner on 11/4/19.
//

import Foundation

#if canImport(UIKit)
import UIKit

public protocol MaskableView where Self: UIView {

    var cornerRadius: CGFloat { get set }
    var roundTLCorner: Bool { get set }
    var roundTRCorner: Bool { get set }
    var roundBRCorner: Bool { get set }
    var roundBLCorner: Bool { get set }
}

public protocol BorderableView where Self: UIView {

    var borderColor: UIColor { get set }
    var borderWidth: CGFloat { get set }
}

extension BorderableView {
    func addBorder() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}

extension BorderableView where Self: MaskableView {
    var shouldShowMask: Bool { borderWidth > 0.001 || cornerRadius >  0.001 }
}

extension MaskableView {
    var cornersToRound: CACornerMask {
        let corners = CACornerMask([])
            .adding(corner: .layerMinXMinYCorner, if: roundTLCorner)
            .adding(corner: .layerMaxXMinYCorner, if: roundTRCorner)
            .adding(corner: .layerMaxXMaxYCorner, if: roundBRCorner)
            .adding(corner: .layerMinXMaxYCorner, if: roundBLCorner)
        return corners
    }

    var UIRectCornersToRound: UIRectCorner {
        let corners = UIRectCorner([])
            .adding(corner: .topLeft, if: roundTLCorner)
            .adding(corner: .topRight, if: roundTRCorner)
            .adding(corner: .bottomRight, if: roundBRCorner)
            .adding(corner: .bottomLeft, if: roundBLCorner)
        return corners
    }

    var shouldShowMask: Bool { cornerRadius >  0.001 }

    func makeRoundedRectPath(for rect: CGRect) -> CGPath {
        UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCornersToRound, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
    }

    func addCorners() {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = cornersToRound
    }
}

public protocol ShaddowableView where Self: UIView {
    var verticalShadowOffset: CGFloat { get set }
    var horizontalShadowOffset: CGFloat { get set }
    var shadowColor: UIColor { get set }
    var shadowOpacity: CGFloat { get set }
}

extension ShaddowableView {

    var shouldShowShaddow: Bool { shadowOpacity > 0.001 }
    var shaddowPathOrigin: CGPoint { CGPoint(x: horizontalShadowOffset, y: verticalShadowOffset) }


    func addShaddow(for rect: CGRect) {
        let path = UIBezierPath(rect: CGRect(origin: shaddowPathOrigin, size: rect.size))
        layer.shadowOpacity = Float(shadowOpacity)
        layer.backgroundColor = backgroundColor?.cgColor
        layer.shadowPath = path.cgPath
    }
}

extension ShaddowableView where Self: MaskableView {
    func addShaddow(for rect: CGRect) {
        let path = makeRoundedRectPath(for: CGRect(origin: shaddowPathOrigin, size: rect.size))
        layer.shadowOpacity = Float(shadowOpacity)
        layer.backgroundColor = backgroundColor?.cgColor
        layer.shadowPath = path
    }
}

#endif
