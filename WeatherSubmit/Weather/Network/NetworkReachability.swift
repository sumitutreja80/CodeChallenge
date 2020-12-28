//
//  NetworkReachability.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import SystemConfiguration

let ReachabilityHostname = "http://api.openweathermap.org/"

extension Notification.Name {
    static let ReachabilityDidChange = Notification.Name("com.sumitweather.ReachabilityUpdatedNotification")
}

@objc public class NetworkReachability: NSObject {

    public enum Status {
        case notReachable
        case reachableViaWiFi
        case reachableViaWWAN
    }

    private let reachability: SCNetworkReachability
    private var trackingChanges: Bool = false

    public static let UserInfoKey = "com.sumitweather.ReachabilityKey"
    
    deinit {
        self.stopTrackingChanges()
    }

    /// Whether the network is currently reachable.
    public var isReachable: Bool {
        switch status {
        case .notReachable:
            return false
        case .reachableViaWiFi, .reachableViaWWAN:
            return true
        }
    }

    public convenience init?(hostname: String) {
        let maybeHostnameUTF8 = (hostname as NSString).utf8String
        guard let hostnameUTF8 = maybeHostnameUTF8 else {
            return nil
        }
        let maybeReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, hostnameUTF8)
        guard let reachability = maybeReachability else {
            return nil
        }
        self.init(reachability: reachability)
    }

    public init(reachability: SCNetworkReachability) {
        self.reachability = reachability
        super.init()
    }

    /// Starts tracking for changes in network reachability status.
    ///
    /// - Returns: `true` if tracking was started successfully, `false` otherwise.
    @discardableResult
    public func startTrackingChanges() -> Bool {
        guard !trackingChanges else {
            return false
        }
        
        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // swiftlint:disable:next multiline_arguments
        let success = SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            if let currentInfo = info {
                let infoObject = Unmanaged<AnyObject>.fromOpaque(currentInfo).takeUnretainedValue()
                if let networkReachability = infoObject as? NetworkReachability {
                    // We need to update lastFlags manually because Reachability object does not always updates itself automatically
                    networkReachability.lastFlags = flags
                    
                    let userInfo = [NetworkReachability.UserInfoKey: flags]
                    NotificationCenter.default.post(name: Notification.Name.ReachabilityDidChange, object: networkReachability, userInfo: userInfo)
                }
            }
        }, &context)
        
        guard success else {
            return false
        }
        
        guard SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.global(qos: .default)) else {
            return false
        }
        
        trackingChanges = true
        return trackingChanges
    }

    /// Stops tracking for changes in network reachability status.
    public func stopTrackingChanges() {
        if trackingChanges {
            SCNetworkReachabilitySetCallback(reachability, nil, nil)
            SCNetworkReachabilitySetDispatchQueue(reachability, nil)
            trackingChanges = false
        }
    }

    private var lastFlags: SCNetworkReachabilityFlags?
    
    private var flags: SCNetworkReachabilityFlags {
        guard let lastFlags = lastFlags else {
            var flags = SCNetworkReachabilityFlags(rawValue: 0)
            let success = withUnsafeMutablePointer(to: &flags) { (flagsPtr) in
                SCNetworkReachabilityGetFlags(reachability, flagsPtr)
            }
            
            if success {
                return flags
            } else {
                return []
            }
        }
        
        return lastFlags
    }
    
    /// The current network reachability status.
    public var status: Status {
        let flags = self.flags
        if !flags.contains(.reachable) {
            return .notReachable
        } else if flags.contains(.isWWAN) {
            return .reachableViaWWAN
        } else if !flags.contains(.connectionRequired) {
            return .reachableViaWiFi
        } else if (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)) && !flags.contains(.interventionRequired) {
            return .reachableViaWiFi
        } else {
            return .notReachable
        }
    }
}
extension NetworkReachability {
    
    /// Singleton reachability object
    @nonobjc public static var shared: NetworkReachability = {
        guard let r = NetworkReachability(hostname: ReachabilityHostname) else {
            fatalError("Could not create a reachability object")
        }
        return r
    }()
    
    /// Returns indication whether network connectivity is available or not
    public static var isNetworkAvailable: Bool {
        return shared.isReachable
    }
}
