//
//  Double+Temperature.swift
//  Weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

extension Double {
    func kelvinToCelsius() -> Double? {
        return self - 273.15
    }
}
