//
//  CheckboxVC.swift
//  ActsLibrariesPackageDescription
//
//  Created by Paul Fechner on 2/25/20.
//

import UIKit
import UIWrappers

open class CheckBoxVC: StackedViewManagerVC<CheckBoxVC>, StackedViewManagerDelegate {

    public struct Data: Equatable {
        public static let empty = Data(options: [])

        public var options: [(title: String, checked: Bool)]

        public init(options: [(title: String, checked: Bool)]) {
            self.options = options
        }

        public mutating func toggle(index: Int) {
            guard index >= 0, index < options.count else { return }
            options[index] = (options[index].title, !options[index].checked)
        }

        public static func == (lhs: CheckBoxVC.Data, rhs: CheckBoxVC.Data) -> Bool {
            guard lhs.options.count == rhs.options.count else { return false }
            return lhs.options.enumerated().first {
                $0.element != rhs.options[$0.offset]
            } == nil
        }
    }

    public struct ViewData: Equatable {
        public let textColor: ColorType
        public let backgroundColor: ColorType

        public init(textColor: ColorType, backgroundColor: ColorType) {
            self.textColor = textColor
            self.backgroundColor = backgroundColor
        }
    }

    public var updatedAction: ((Data) -> ())?

    open var data: Data = .empty {
        didSet {
            if data != oldValue {
                dataChanged()
            }
        }
    }
    public var uncheckedState: ViewData = ViewData(textColor: .color(.black), backgroundColor: .color(.white)) {
        didSet {
            if uncheckedState != oldValue { dataChanged() }
        }
    }
    public var checkedState: ViewData = ViewData(textColor: .color(.white), backgroundColor: .color(.darkGray)) {
           didSet {
               if uncheckedState != oldValue { dataChanged() }
           }
       }
    public var pressedState: ViewData = ViewData(textColor: .color(.black), backgroundColor: .color(.lightGray)) {
           didSet {
               if uncheckedState != oldValue { dataChanged() }
           }
       }

    public var numberOfViews: Int { data.options.count }

    open override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
    }
    open func makeView() -> UIButton {
        let button = UIButton(type: .system)
        return button
    }

    open func update(views: [UIButton]) {
        views.enumerated().forEach {
            $0.element.setTitle(data.options[$0.offset].title, for: .normal)
            $0.element.addTarget(self, action: #selector(buttonWasTapped(_:)), for: .touchUpInside)
            if data.options[$0.offset].checked {
                $0.element.backgroundColor = checkedState.backgroundColor.color
                $0.element.tintColor = checkedState.textColor.color
            }
            else {
                $0.element.backgroundColor = uncheckedState.backgroundColor.color
                $0.element.tintColor = uncheckedState.textColor.color
            }
        }
    }

    private func setupStates(for button: UIButton) {
        button.setTitleColor(checkedState.textColor.color, for: .selected)
        button.setTitleColor(uncheckedState.textColor.color, for: .normal)
        button.setTitleColor(pressedState.textColor.color, for: .highlighted)
    }

    private let impacter = UIImpactFeedbackGenerator(style: .light)

    @IBAction public func buttonWasTapped(_ button: UIButton) {
        guard let index = managedViews.firstIndex(of: button) else {
            assertionFailure("Invalid view appears to exist in CheckBoxVC.managedViews")
            return
        }
        impacter.impactOccurred()
        data.toggle(index: index)
        updatedAction?(data)

    }
}
