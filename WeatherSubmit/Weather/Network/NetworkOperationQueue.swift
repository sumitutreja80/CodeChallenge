//
//  NetworkOperationQueue.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation


public class NetworkOperationQueue: NSObject {

    /// Used to indicate the nature and importance of work to the system.
    /// Work with higher quality of service receive higher execution priority than work with lower quality of service.
    enum QualityOfService {
        case userInteractive
        case userInitiated
        case utility
        case background
        
        /// Returns queue priority for service type
        var queuePriority: Operation.QueuePriority {
            switch self {
            case .userInteractive:
                return .veryHigh
            case .userInitiated:
                return .high
            case .utility:
                return .normal
            case .background:
                return .low
            }
        }
    }

    /// NetworkOperationQueue OperationQueue`.
    public let queue = OperationQueue()
    
    /// Total Operation count in queue.
    public var operationCount: Int {
        return queue.operationCount
    }
    
    /// Operation`s currently in queue.
    public var operations: [Operation] {
        return queue.operations
    }
    
    /// Returns if the queue is executing or is in pause.
    /// Call resume() to make it running.
    /// Call pause() to make to pause it.
    public var isExecuting: Bool {
        return !queue.isSuspended
    }
    
    /// Define the max concurrent Operation`s count.
    public var maxConcurrentOperationCount: Int {
        get {
            return queue.maxConcurrentOperationCount
        }
        set {
            queue.maxConcurrentOperationCount = newValue
        }
    }
    
    /// Creates a new queue.
    ///
    /// - Parameters:
    ///   - name: Custom queue name.
    ///   - maxConcurrentOperationCount: The max concurrent Operation`s count.
    ///   - qualityOfService: The default service level to apply to Operation`s executed using the queue.
    override init() {
        super.init()
        self.maxConcurrentOperationCount = 3
    }

    /// Cancel all Operation`s in queue.
    public func cancelAll() {
        queue.cancelAllOperations()
    }

    /// Suspends all operations in the queue
    func suspendAll() {
        queue.isSuspended = true
    }

    /// Pause the queue.
    public func pause() {
        queue.isSuspended = true
        
        for operation in queue.operations {
            if let concurrentOperation = operation as? ConcurrentOperation {
                concurrentOperation.pause()
            }
        }
    }
    
    /// Resume the queue.
    public func resume() {
        queue.isSuspended = false
    }

    /// Add an Operation to be executed asynchronously.
    ///
    /// - Parameter operation: Operation to be executed.
    func addOperation(_ operation: Operation, qos: QualityOfService) {
        add(operations: [operation], qos: qos)
    }

    /// Adds a list of operations to the queue, setting expected queue priority based on given quality of service.
    ///
    /// - Parameters:
    ///   - operations: List of operations to add into the queue.
    func add(operations: [Operation], qos: QualityOfService) {
        let qos: QualityOfService = .userInitiated
        let priority = qos.queuePriority

        operations.forEach {
            $0.queuePriority = priority
        }

        queue.addOperations(operations, waitUntilFinished: false)

    }
}
