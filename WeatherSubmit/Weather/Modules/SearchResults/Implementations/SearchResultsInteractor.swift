//
//  SearchResultsInteractor.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
class SearchResultsInteractor <T1: BaseCommand> : BaseInteractor {
    weak var presenter: SearchResultsPresenting?
    private var weatherCmd: T1?
    fileprivate var instance: CrudAPI?

    override func getDBData() -> [WeatherCity] {
        return super.getDBData()
    }

}


extension SearchResultsInteractor: SearchResultsInteracting {
    func buildRequest<B: BaseRequest>(request: B?, vmO: WeatherOutput) {
        let cityParam = URLQueryItem.init(name: "q", value: vmO.cityName)
        let apiKeyParam = URLQueryItem.init(name: "appid", value: "1a99b0b93a74687ee1d139242dea63b6")
        let params = Parameters.url([cityParam, apiKeyParam])
        request?.parameters = params
    }

    func loadData(_ vmO: WeatherOutput,  completion: @escaping (Decodable?, Error?) -> ()) {
        weatherCmd = T1()

        let weatherReq = WeatherCityRequest.init()

        self.buildRequest(request: weatherReq, vmO: vmO)
        (weatherCmd as? WeatherCityCommand)?.executeTask(request: weatherReq,
                                                 type: WeatherCity.self,
                                                 completion: completion)
    }

    func loadData(completion: @escaping (Decodable?, Error?) -> ()) {
        weatherCmd = T1()

        let weatherReq = WeatherCityRequest.init()
        (weatherCmd as? WeatherCityCommand)?.executeTask(request: weatherReq,
                                                         type: WeatherCity.self,
                                                         completion: { (data, error) in
                                                            completion(data, error)
                                                            if let d = data {
                                                                DispatchQueue.main.async {
                                                                    self.instance = CrudAPI.sharedInstance
                                                                    self.instance?.saveCity(d)
                                                                }
                                                            }
        })
    }
    
    func stop() {
    }
        
    func willReload<T: Decodable>(withData: [T],
                          completion: @escaping ([T]) -> ()) {
        // Filter is not used
    }

    func saveAsFav2DB(_ cityId: Int) {
        self.instance = CrudAPI.sharedInstance
        self.instance?.saveCityAsFav(cityId)
    }

    func saveCityObjectToDB(_ weatherCity: WeatherCity) {
        self.instance = CrudAPI.sharedInstance
        self.instance?.saveCity(weatherCity)
    }
}
