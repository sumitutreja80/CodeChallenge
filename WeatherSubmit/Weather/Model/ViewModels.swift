//
//  ViewModels.swift
//  weather
//
//  Created by Utreja, Sumit on 21/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class WeatherResult {
    var currTemp: Double?
    var mainDesc: String?
    var windDesc: String?
    var humidity: Double?
    var pressure: Double?
    var minTemp: Double?
    var maxTemp: Double?
    var name: String?
    var cityId: Int?
    var isFav: Bool?
}

class WeatherOutput {
    var cityName: String?
}
