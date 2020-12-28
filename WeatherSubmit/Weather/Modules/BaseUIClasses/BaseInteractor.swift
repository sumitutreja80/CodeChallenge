//
//  BaseInteractor.swift
//  Weather
//
//  Created by Utreja, Sumit on 23/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class BaseInteractor {
    func getDBData() -> [WeatherCity] {
        let instance: CrudAPI = CrudAPI.sharedInstance
        var arr: [WeatherCity] = []

        let arrDB: [WWeatherCity] = instance.getAllCities()
        // convert the managed object to the model
        for element in arrDB {
            var weathItem = WeatherCity()

            weathItem.base = element.base
            weathItem.cod = Int(element.cod)
            weathItem.id = Int(element.id)
            weathItem.dt = Int(element.dt)
            weathItem.name = element.name

            weathItem.coord = Coord()
            weathItem.coord?.lon = element.coord?.lon
            weathItem.coord?.lat = element.coord?.lat

            weathItem.clouds = Clouds()
            weathItem.clouds?.all = Int(element.clouds?.all ?? 0)

            weathItem.sys = Sys()
            weathItem.sys?.id = Int(element.sys?.id ?? 0)

            weathItem.main = Main()
            weathItem.main?.feelsLike = element.main?.feelsLike
            weathItem.main?.temp = element.main?.temp
            weathItem.main?.tempMax = element.main?.tempMax
            weathItem.main?.tempMin = element.main?.tempMin
            
            arr.append(weathItem)
        }

        return arr
    }

}
