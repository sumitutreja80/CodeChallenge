//
//  SearchResultsPresenter.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class SearchResultsPresenter {
    var interactor: SearchResultsInteracting?
    weak var view: SearchResultsInterface?
    fileprivate var results: [WeatherResult] = []
    fileprivate var searchResults: [WeatherCity] = []
    var router: SearchResultsRouting?
}

extension SearchResultsPresenter: SearchResultsPresenting {
    func fetchResults(_ searchText: String?) {
        let vm = WeatherOutput.init()
        vm.cityName = searchText
        self.interactor?.loadData(vm, completion: { (responseData, error) in
            if let d: WeatherCity = responseData as? WeatherCity {
                self.searchResults.append(d)
                self.view?.load(self.modelToViewModel(d))
            }
        })
    }

    func getCachedResponse() -> [WeatherResult] {
        // convert model to view model
        if let dbVal = self.interactor?.getDBData() {
            for item in dbVal {
                self.results.append(self.modelToViewModel(item))
            }
        }
        
        return self.results
    }
    
    func viewDidLoad() {
        self.interactor?.loadData {(data, error) in
            // convert model to ViewModel
            if let d: WeatherCity = data as? WeatherCity {
                self.view?.load(self.modelToViewModel(d))
            }
        }
    }

    private func modelToViewModel(_ data: WeatherCity) -> WeatherResult {
        let result = WeatherResult()
    
        result.mainDesc = data.weather?[0].weatherDescription
        // convert kelvin to celcius
        result.currTemp = data.main?.temp?.kelvinToCelsius()
        result.name = data.name
        result.cityId = data.id
        
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

    func handleCellSubViewTap(eventPayload: WeatherCityEvent) {
        // handle the tap scenarios
        switch eventPayload {
        case .kEventRequestedFor(let cityId):
            self.interactor?.saveAsFav2DB(cityId ?? 0)
            self.addFav2WeatherDB(cityId)
            break
        case .kNoneEvent:
            break
        case .kEventTap:
            break
        }
    }

    func addFav2WeatherDB(_ cityId: Int?) {
        if let id = cityId {
            var object: WeatherCity? = nil

            let isExists = self.searchResults.contains { (obj) -> Bool in
                if obj.id == id {
                    object = obj
                    return true
                }
                return false
            }
            if isExists == true {
                if let ob = object {
                    self.interactor?.saveCityObjectToDB(ob)
                }
            }
        }
    }

    func handleBackButtonTap() {
        self.router?.navigate(to: .BackToSearch)
    }
}
