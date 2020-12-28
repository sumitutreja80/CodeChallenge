//
//  SearchCityPresenter.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import CoreLocation

class SearchCityPresenter: NSObject, CLLocationManagerDelegate {
    var interactor: SearchCityInteracting?
    weak var view: SearchCityInterface?
    var router: SearchCityRouting?

    private var locationManager: LocationManager?

}

extension SearchCityPresenter: SearchCityPresenting {
    func viewDidLoad() {
        locationManager = LocationManager.init()
        locationManager?.getlocationForUser(userLocationClosure: { (clLocation) in
            if clLocation.coordinate.latitude == 0.0 && clLocation.coordinate.longitude == 0.0 {
                // no location. get last fetched from DB
                if let data = self.interactor?.loadFromDB(), data.count > 0 {
                    // convert model to ViewModel
                    let d: WeatherCity = data[0]
                    self.view?.load(self.modelToViewModel(d))
                }
            } else {
                // get the name from the location
                self.locationManager?.lookUpCurrentLocation(completionHandler: { (clPlacemark) in
                    print("\(clPlacemark?.locality ?? "")")
                    let vm = WeatherOutput.init()
                    vm.cityName = clPlacemark?.locality

                    self.interactor?.loadData(vm) {(data, error) in
                        // convert model to ViewModel
                        if let d: WeatherCity = data as? WeatherCity {
                            self.view?.load(self.modelToViewModel(d))
                        }
                    }

                })
            }
        })
    }

    private func modelToViewModel(_ data: WeatherCity) -> WeatherResult {
        let result = WeatherResult()
    
        result.name = data.name
        result.mainDesc = data.weather?[0].weatherDescription
        // convert kelvin to celcius
        result.currTemp = data.main?.temp?.kelvinToCelsius()
        
        return result
    }
    
    func viewDidAppear() {
    }
    
    func viewDidDisappear() {
        self.stop()
    }
    

    func stop() {
        self.interactor?.stop()
    }
 
    func handleSearchTap() {
        self.router?.navigate(to: .SearchCity)
    }
}

