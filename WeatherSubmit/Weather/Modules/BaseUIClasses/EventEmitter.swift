//
//  EventEmitter.swift
//  Weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

public protocol EventEmitterType: class {
    
    typealias EventCallbackClosure = ([String: Any]) -> Void
    
    /**
     Function adds subscriber's callback to
     - parameters:
     - listener: returns the `[AnyHashable: Any]` dictionary that contains all kinds of parameters which are convention for each particular
     */
    func subscribe(_ listener: @escaping EventCallbackClosure)
    
    /**
     Deletes all subscribers
     */
    func unsubscribeAll()
    
    /**
     Contains collection of all subscriber's callback closures
     */
    var callbacks: [EventCallbackClosure] { get set }
    
    /**
     Queue used for notifying
     */
    var serialQueue: DispatchQueue { get set }
    
    /**
     Function which notifies all the "closures" with the passed payload
     */
    func notify(eventPayload: [String: Any])
}

extension EventEmitterType {
    
    func subscribe(_ listener: @escaping EventCallbackClosure) {
        callbacks.append(listener)
    }
    
    func unsubscribeAll() {
        callbacks.removeAll()
    }
    
    func notify(eventPayload: [String: Any]) {
        serialQueue.sync {
            callbacks.forEach { $0(eventPayload) }
        }
    }
}

/**
 This protocol should be adopted by any object which wants to emit or receive the events
 */
public protocol EventEmitting {
    associatedtype EventEmitter: EventEmitterType
    var eventEmitter: EventEmitter? { get set }
}


class BaseEventEmitter: EventEmitterType {
    var serialQueue: DispatchQueue
    
    var callbacks: [EventCallbackClosure] = []
    init(queueName: String) {
        serialQueue = DispatchQueue(label: queueName)
    }
}

/**
 Events
 */
enum WeatherCityEvent {
    case kNoneEvent
    case kEventRequestedFor(cityId: Int?)
    case kEventTap
}
