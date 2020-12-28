//
//  WeatherCityRequest.swift
//  weather
//
//  Created by Utreja, Sumit on 19/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class WeatherCityRequest : BaseRequest {
    override var requestHeaders: [String : Any] {
        return ["Content-Type": "application/json"]
    }

    override var method: MethodType {
        return .get
    }
}
