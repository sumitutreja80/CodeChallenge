//
//  File.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

open class ConcurrentOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.sumitweather.asyncoperation", attributes: .concurrent)

    override open var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting: Bool = false
    override open private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override open private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    override open func start() {
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    override open func main() {
        /// Use a dispatch after to mimic the scenario of a long-running task.
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            print("Executing")
            self.finish()
        })
    }

    open func finish() {
        isExecuting = false
        isFinished = true
    }

    /// Pause the current Operation, if it's supported.
    /// Must be overridden by a subclass to get a custom pause action.
    func pause() {}
    
    /// Resume the current Operation, if it's supported.
    /// Must be overridden by a subclass to get a custom resume action.
    func resume() {}
}

/// `ConcurrentOperation` extension with queue handling.
extension ConcurrentOperation {
    /// Adds the Operation to `shared` OperationQueue.
    func addToSharedQueue(qos: NetworkOperationQueue.QualityOfService = .userInitiated) {
//        #if UNITTESTING
//        let session = UserSession(with: "dummy")
//        let opQueue = session.networkOperationQueue
//        opQueue.addOperation(self, qos: qos)
//        #else
        let opQueue = UserSession.activeSession?.networkOperationQueue
        opQueue?.addOperation(self, qos: qos)
//        #endif
    }
}
