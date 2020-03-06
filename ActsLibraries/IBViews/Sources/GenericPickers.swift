//
//  GenericPickers.swift
//  
//
//  Created by Paul Fechner on 3/2/20.
//

import UIKit

public protocol PickerComponentData: Equatable {
    static var `default`: Self { get }
    static var options: [Self] { get }

    var pickerLabelText: String { get }
}

public extension PickerComponentData where Self: CaseIterable, AllCases == Array<Self> {
    static var options: [Self] { allCases }
}

public extension PickerComponentData where Self: RawRepresentable, RawValue == String {
    var pickerLabelText: String { rawValue }
}

open class SinglePicker<Data: PickerComponentData>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    public var currentSelection: Data { Data.options[selectedRow] }

    public var selectionAction: ((Data) -> ())?

    public var selectedRow: Int { selectedRow(inComponent: 0) }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        doSetup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        doSetup()
    }

    private func doSetup() {
        self.delegate = self
        self.dataSource = self
        select(currentSelection, animated: false)
    }

    public func select(_ data: Data, animated: Bool) {
        if let selectedIndex = Data.options.firstIndex(where: { $0 == data }) {
            self.selectRow(selectedIndex, inComponent: 0, animated: animated)
        }
        else {
            assertionFailure("Invalid data selected: \(data)")
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Data.options.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Data.options[row].pickerLabelText
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionAction?(currentSelection)
    }
}

open class DoublePicker<Data0: PickerComponentData, Data1: PickerComponentData>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    public var currentSelection: (Data0, Data1) {
        let selections = selectedRows
        return (Data0.options[selections.0], Data1.options[selections.1])
    }

    public var selectionAction: (((Data0, Data1)) -> ())?

    public var selectedRows: (Int, Int) { (selectedRow(inComponent: 0), selectedRow(inComponent: 1)) }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        doSetup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        doSetup()
    }

    private func doSetup() {
        self.delegate = self
        self.dataSource = self
        select(currentSelection, animated: false)
    }

    public func select(_ data: (Data0, Data1), animated: Bool) {
        if let selectedIndex = Data0.options.firstIndex(where: { $0 == data.0 }) {
            selectRow(selectedIndex, inComponent: 0, animated: animated)
        }
        else {
            assertionFailure("Invalid data selected: \(data.0)")
        }
        if let selectedIndex = Data1.options.firstIndex(where: { $0 == data.1 }) {
            selectRow(selectedIndex, inComponent: 1, animated: animated)
        }
        else {
            assertionFailure("Invalid data selected: \(data.1)")
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return Data0.options.count
        default: return Data1.options.count
        }
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return Data0.options[row].pickerLabelText
        default: return Data1.options[row].pickerLabelText
        }
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionAction?(currentSelection)
    }
}

open class TriplePicker<Data0: PickerComponentData, Data1: PickerComponentData, Data2: PickerComponentData>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    public var currentSelection: (Data0, Data1, Data2) {
        let selections = selectedRows
        return (Data0.options[selections.0], Data1.options[selections.1], Data2.options[selections.2])
    }

    public var selectionAction: (((Data0, Data1, Data2)) -> ())?

    public var selectedRows: (Int, Int, Int) { (selectedRow(inComponent: 0), selectedRow(inComponent: 1), selectedRow(inComponent: 2)) }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        doSetup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        doSetup()
    }

    private func doSetup() {
        self.delegate = self
        self.dataSource = self
        select(currentSelection, animated: false)
    }

    public func select(_ data: (Data0, Data1, Data2), animated: Bool) {
        if let selectedIndex = Data0.options.firstIndex(where: { $0 == data.0 }) {
            selectRow(selectedIndex, inComponent: 0, animated: animated)
        }
        else {
            assertionFailure("Invalid data selected: \(data.0)")
        }
        if let selectedIndex = Data1.options.firstIndex(where: { $0 == data.1 }) {
            selectRow(selectedIndex, inComponent: 1, animated: animated)
        }
        else {
            assertionFailure("Invalid data selected: \(data.1)")
        }
        if let selectedIndex = Data2.options.firstIndex(where: { $0 == data.2 }) {
            selectRow(selectedIndex, inComponent: 2, animated: animated)
        }
        else {
            assertionFailure("Invalid data selected: \(data.2)")
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return Data0.options.count
        case 1: return Data1.options.count
        default: return Data2.options.count
        }
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return Data0.options[row].pickerLabelText
        case 1: return Data1.options[row].pickerLabelText
        default: return Data2.options[row].pickerLabelText
        }
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionAction?(currentSelection)
    }
}
