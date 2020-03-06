//
//  StackedViewManager.swift
//  ActsLibrariesPackageDescription
//
//  Created by Paul Fechner on 2/25/20.
//

import UIKit

public protocol StackedViewManagerDelegate {
    associatedtype ViewType: UIView
    var numberOfViews: Int { get }
    func makeView() -> ViewType
    func update(views: [ViewType])
}

open class StackedViewManagerVC<Delegate: StackedViewManagerDelegate>: UIViewController {

    @IBOutlet public weak var stackView: UIStackView!

    public private(set) var managedViews: [Delegate.ViewType] = []
    public var delegate: Delegate?

    open override func viewDidLoad() {
        super.viewDidLoad()
        // make sure we're starting blank
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        equalizeViews()
    }

    open func dataChanged() {
        equalizeViews()
        delegate?.update(views: managedViews)
    }

    private func equalizeViews() {
        let changeNeeded = (delegate?.numberOfViews ?? 0) - stackView.arrangedSubviews.count
        switch changeNeeded {
        case ..<0: removeManagedViews(numberToRemove: abs(changeNeeded))
        case 1...: addManagedViews(numberToAdd: changeNeeded)
        default: return
        }
    }

    private func removeManagedViews(numberToRemove: Int) {
        (0..<numberToRemove).forEach { _ in
            managedViews.removeLast().removeFromSuperview()
        }
    }

    private func addManagedViews(numberToAdd: Int) {
        (0..<numberToAdd).forEach { _ in
            if let newView = delegate?.makeView() {
                stackView.addArrangedSubview(newView)
                managedViews.append(newView)
            }
        }
    }
}
