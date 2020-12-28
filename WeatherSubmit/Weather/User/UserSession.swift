//
//  UserSession.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class UserSession {
    /// Property for accessing the active session. Nil if there is no session.
    private(set) static var activeSession: UserSession?

   /// The reference to the NetworkController of the application
    lazy var networkOperationQueue: NetworkOperationQueue = {
        NetworkOperationQueue()
    }()

    /// Convinient user session cleanup method to guarantee that current active session is discarded.
    /// Method performs cleanup only, without actually logging out user from authenticator.
    /// If full logout is required then user logout method instead.
    func shutdown() {
        prepareForShutdown()
        
        if UserSession.activeSession === self {
            UserSession.activeSession = nil
        }
    }
    
    private func prepareForShutdown() {
        cancelAll()
    }
    
    /// Cancels all operations.
    func cancelAll() {
        networkOperationQueue.cancelAll()
    }
    
    /// Suspends all operations.
    func suspendAll() {
        networkOperationQueue.suspendAll()
    }
    
    /// Resumes all operations.
    func resumeAll() {
        networkOperationQueue.resume()
    }

    @discardableResult
    init(with username: String) {
        
        if let currentSession = UserSession.activeSession {
            currentSession.shutdown()
        }
        
        UserSession.activeSession = self
    }
}
