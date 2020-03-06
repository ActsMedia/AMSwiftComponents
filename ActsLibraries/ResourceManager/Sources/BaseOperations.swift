//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/12/20.
//

import Foundation

//MARK: - ConcurrentOperation

internal class ConcurrentOperation: Operation {

    override var isAsynchronous: Bool { true }

    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }

    override var isExecuting: Bool {
        return _executing
    }

    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }

        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isFinished: Bool {
        return _finished
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        executing(true)
        execute()
        executing(false)
        finish(true)
    }

    /// Must be implemented by subclass
    open func execute() {
        assertionFailure("Must be overridden by sub-class")
    }

    private func executing(_ executing: Bool) {
        _executing = executing
    }

    private func finish(_ finished: Bool) {
        _finished = finished
    }
}

//MARK: - AsyncOperation

internal class AsyncOperation: Operation {

    override var isAsynchronous: Bool { true }

    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }

    override var isExecuting: Bool {
        return _executing
    }

    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }

        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isFinished: Bool {
        return _finished
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        executing(true)
        execute(completion: finishOperation)
    }

    func finishOperation() {
        executing(false)
        finish(true)
    }

    /// Must be implemented by subclass
    open func execute(completion: @escaping () -> ()) {
        assertionFailure("Must be overridden by sub-class")
    }

    private func executing(_ executing: Bool) {
        _executing = executing
    }

    private func finish(_ finished: Bool) {
        _finished = finished
    }
}





