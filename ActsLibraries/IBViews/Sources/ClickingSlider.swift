//
//  ClickingSlider.swift
//  
//
//  Created by Paul Fechner on 3/6/20.
//

import UIKit

open class ClickingSlider: UISlider {

    //MARK: Public properties

    @IBInspectable
    public var numberOfClicks: Int = 5

    /// 0 through (numberOfClicks - 1)
    @IBInspectable
    public var defaultClick: Int = 2

    private var _currentClick: Int = 2

    public var currentClick: Int {
        get {
            calculateClickFromValue(value)
        }
        set {
            if newValue != _currentClick {
                _currentClick = newValue
                sendUpdate()
            }
            value = calculateValueFromClick(newValue)
        }
    }

    public var currentRatio: Float {
        get {
            let clickValue = calculateValueFromClick(currentClick)
            return calculateRatioFromValue(clickValue)
        }
        set(newRatio) {
            value = calculateValueFromRatio(newRatio)
        }
    }

    public var valueChangedAction: ((ClickingSlider) -> ())?

    //MARK: Private Properties

    private let impacter = UIImpactFeedbackGenerator(style: .light)

    //MARK: Computed Properties

    private var clickDistance: Float {
        (maximumValue - minimumValue) / Float(numberOfClicks - 1)
    }

    private var calculatedClickValues: [Float] { (0..<numberOfClicks).map(calculateValueFromClick(_:)) }

    //MARK: Setup

    public override func awakeFromNib() {
        doSetup()
    }

    private func doSetup() {
        addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        addTarget(self, action: #selector(valueChanged(_:)), for: .editingDidEnd)
        self.value = calculateValueFromClick(defaultClick)
    }

    //MARK: Responders

    @objc func valueChanged(_: Any?) {
        updateValueToCurrentClick()
    }

    @objc func editingEnded(_: Any?) {
        updateValueToCurrentClick()
    }

    //MARK: Updates

    private func updateValueToCurrentClick() {
        currentClick = calculateClickFromValue(value)
    }

    private func sendUpdate() {
        impacter.impactOccurred()
        valueChangedAction?(self)
    }

    //MARK: Calculations

    private func calculateRatioFromValue(_ value: Float) -> Float {
        let ratio = (value - minimumValue) / (maximumValue - minimumValue)
        return ratio
    }
    private func calculateValueFromRatio(_ ratio: Float) -> Float {
        let value = minimumValue + ((maximumValue - minimumValue) * ratio)
        return value
    }

    private func calculateClickFromValue(_ value: Float) -> Int {
        let distances = calculatedClickValues.enumerated().map{ ($0.offset, abs($0.element - value))}
        let closestClick = distances.sorted { $0.1 < $1.1 }.first?.0 ?? 0
        return closestClick
    }

    private func calculateValueFromClick(_ click: Int) -> Float {
        return minimumValue + (Float(click) * clickDistance)
    }
}
