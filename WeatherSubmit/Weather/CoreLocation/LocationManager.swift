//
//  LocationManager.swift
//  Weather
//
//  Created by Utreja, Sumit on 23/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func getlocationForUser(userLocationClosure: @escaping ((_ userLocation: CLLocation) -> ()))
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
    -> Void )
}

class LocationManager: NSObject, CLLocationManagerDelegate, LocationManagerDelegate {
    
    let manager: CLLocationManager
    var locationManagerClosures: [((_ userLocation: CLLocation) -> ())] = []
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
        self.manager.requestAlwaysAuthorization()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //This is the main method for getting the users location and will pass back the usersLocation when it is available
    func getlocationForUser(userLocationClosure: @escaping ((_ userLocation: CLLocation) -> ())) {

        func noLocation() {
            // may be user denied access outside the app.
            let tempClosures = self.locationManagerClosures
            for closure in tempClosures {
                closure(CLLocation.init(latitude: 0.0, longitude: 0.0))
            }
        }

        self.locationManagerClosures.append(userLocationClosure)
        
        //First need to check if the apple device has location services availabel. (i.e. Some iTouch's don't have this enabled)
        if CLLocationManager.locationServicesEnabled() {
            //Then check whether the user has granted you permission to get his location
            if CLLocationManager.authorizationStatus() == .notDetermined {
                //Request permission
                //Note: you can also ask for .requestWhenInUseAuthorization
                manager.requestWhenInUseAuthorization()
            } else if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                //... Sorry for you. You can huff and puff but you are not getting any location
                noLocation()
            } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                // This will trigger the locationManager:didUpdateLocation delegate method to get called when the next available location of the user is available
                manager.startUpdatingLocation()
            }
        } else {
            noLocation()
        }
        
    }
    
    //MARK: CLLocationManager Delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Because multiple methods might have called getlocationForUser: method there might me multiple methods that need the users location.
        //These userLocation closures will have been stored in the locationManagerClosures array so now that we have the users location we can pass the users location into all of them and then reset the array.
        let tempClosures = self.locationManagerClosures
        for closure in tempClosures {
            closure(locations[0])
        }
        self.locationManagerClosures = []
    }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.manager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
}
