//
//  WeatherCityRepository.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class WeatherCityRepository : NSObject, IRepository {
    typealias T = WeatherCity
    typealias R = WeatherCityRequest

    var request: R?

    /// Get the data for the request.
    ///
    /// - Parameter completion: The completion block to invoke after response.
    @discardableResult
    func get(completion: @escaping (T?, Error?) -> ()) -> String {
        return self.get(forRequest: request!) { (response, error) in
            completion(response, error)
        }
    }
    
    required init(with requestValue: R) {
        request = requestValue
    }

}
