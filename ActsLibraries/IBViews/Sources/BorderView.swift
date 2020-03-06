//
//  File.swift
//  
//
//  Created by Paul Fechner on 11/4/19.
//

#if canImport(UIKit)
import UIKit

open class BorderView: UIView, MaskableView, BorderableView {

    //MARK: border
    @IBInspectable
    open var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundTLCorner: Bool = true {
        didSet {
            layer.maskedCorners = cornersToRound
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundTRCorner: Bool = true {
        didSet {
            layer.maskedCorners = cornersToRound
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundBRCorner: Bool = true {
        didSet {
            layer.maskedCorners = cornersToRound
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundBLCorner: Bool = true {
        didSet {
            layer.maskedCorners = cornersToRound
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    private var shouldShowMask: Bool { borderWidth > 0.001 || cornerRadius >  0.001 }
    private var attributesHaveChanged: Bool = false
    private var lastDrawnRect = CGRect.zero
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard rect != lastDrawnRect || attributesHaveChanged, shouldShowMask  else {
            return
        }
        attributesHaveChanged = true
        lastDrawnRect = rect

        addBorder()
        addCorners()
    }
}

#endif
