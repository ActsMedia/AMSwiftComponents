//
//  File.swift
//  
//
//  Created by Paul Fechner on 11/4/19.
//

#if canImport(UIKit)
import UIKit

open class ShaddowView: UIView, ShaddowableView, MaskableView {

    @IBInspectable
    open var cornerRadius: CGFloat = 0 {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundTLCorner: Bool = true {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
       }
   }

    @IBInspectable
    open var roundTRCorner: Bool = true {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundBRCorner: Bool = true {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var roundBLCorner: Bool = true {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    //MARK: Shadow
    @IBInspectable
    open var verticalShadowOffset: CGFloat = 0.0 {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var horizontalShadowOffset: CGFloat = 0.0 {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var shadowColor: UIColor = UIColor.clear {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    @IBInspectable
    open var shadowOpacity: CGFloat = 0.0 {
        didSet {
            attributesHaveChanged = true
            setNeedsDisplay()
        }
    }

    private var attributesHaveChanged = false
    private var lastDrawnRect = CGRect.zero

    override public init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = false
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard shouldShowShaddow, rect != lastDrawnRect || attributesHaveChanged else {
            return
        }

        attributesHaveChanged = false
        lastDrawnRect = rect
        addShaddow(for: rect)
    }
}
#endif
