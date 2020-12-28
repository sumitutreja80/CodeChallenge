//
//  CrudApis.swift
//  Weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import UIKit
import CoreData

/**
    CityCrud API contains the endpoints to Create/Read/Update/Delete Cities.
*/
class CrudAPI {

    fileprivate let persistenceManager: PersistenceManager!
    fileprivate var mainContextInstance: NSManagedObjectContext!

    //Utilize Singleton pattern by instanciating CrudAPI only once.
    class var sharedInstance: CrudAPI {
        struct Singleton {
            static let instance = CrudAPI()
        }

        return Singleton.instance
    }

    init() {
        self.persistenceManager = PersistenceManager.sharedInstance
        self.mainContextInstance = persistenceManager.getMainContextInstance()
    }

    /**
     Retrieve a City
     
     Scenario:
     Given that there there is only a single city in the datastore
     Let say we only created one city in the datastore, then this function will get that single persisted city
     Thus calling this method multiple times will result in getting always the same city.
     
     - Returns: a found city item, or nil
     */
    func getSingleAndOnlyCity(cityName: String) -> WWeatherCity? {
        var fetchedResult: WWeatherCity?
        
        // Create request on WWeatherCity entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WWeatherCity")
        
        //Execute Fetch request
        do {
            let fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [WWeatherCity]
            fetchRequest.fetchLimit = 1
            
            if fetchedResults.count != 0 {
                fetchedResult =  fetchedResults.first
            }
        } catch let fetchError as NSError {
            print("retrieve single city error: \(fetchError.localizedDescription)")
        }
        
        return fetchedResult
    }
    
    // MARK: Create

    func saveCityAsFav(_ cityId: Int) {
        func addEntity() {
            //Minion Context worker with Private Concurrency type.
            let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
            minionManagedObjectContextWorker.parent = self.mainContextInstance

            //Create new Object of weathery entity
            let item = NSEntityDescription.insertNewObject(forEntityName: "FavouriteCities",
                into: minionManagedObjectContextWorker) as! FavouriteCities

            //Assign field values
            item.setValue(cityId, forKey: "id")

            //Save current work on Minion workers
            self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)

            //Save and merge changes from Minion workers with Main context
            self.persistenceManager.mergeWithMainContext()

            //Post notification to update datasource of a given Viewcontroller/UITableView
            self.postUpdateNotification()

        }
        let arrDB: [WWeatherCity] = self.getAllCities()
        if arrDB.count > 0 {
            for element in arrDB {
                if Int(element.id) == cityId {
                    // we found the city
                    // add it to the fav table.
                    addEntity()
                    break
                }
            }
        } else {
            addEntity()
        }
    }
    
    /**
        Create a single  item, and persist it to Datastore via Worker(minion),
        that synchronizes with Main context.
    
        - Parameter weatherCity: <Dictionary<String, AnyObject> A single item to be persisted to the Datastore.
        - Returns: Void
    */
    func saveCity(_ weatherCity: WeatherCity) {

        // check if city already present.
        let arrDB: [WWeatherCity] = self.getAllCities()
        if arrDB.count > 0 {
            for element in arrDB {
                if (element.value(forKey: "id") as? Int) == weatherCity.id {
                    // we already have this city. no need to add.
                    return
                }
            }
        }
        
        //Minion Context worker with Private Concurrency type.
        let minionManagedObjectContextWorker: NSManagedObjectContext =
        NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance

        //Create new Object of weathery entity
        let item = NSEntityDescription.insertNewObject(forEntityName: "WWeatherCity",
            into: minionManagedObjectContextWorker) as! WWeatherCity

        //Assign field values
        item.setValue(weatherCity.base, forKey: "base")
        item.setValue(weatherCity.cod, forKey: "cod")
        item.setValue(weatherCity.dt, forKey: "dt")
        item.setValue(weatherCity.name, forKey: "name")
        item.setValue(weatherCity.id, forKey: "id")

        // Main
        let itemMain = NSEntityDescription.insertNewObject(forEntityName: "WMain",
            into: minionManagedObjectContextWorker) as! WMain

        itemMain.setValue(weatherCity.main?.temp, forKey: "temp")
        itemMain.setValue(weatherCity.main?.tempMax, forKey: "tempMax")
        itemMain.setValue(weatherCity.main?.tempMin, forKey: "tempMin")
        itemMain.setValue(weatherCity.main?.humidity, forKey: "humidity")
        itemMain.setValue(weatherCity.main?.pressure, forKey: "pressure")
        itemMain.setValue(weatherCity.main?.feelsLike, forKey: "feelsLike")

        item.setValue(itemMain, forKey: "main")

        // Wind
        let itemWind = NSEntityDescription.insertNewObject(forEntityName: "WWind",
            into: minionManagedObjectContextWorker) as! WWind

        itemWind.setValue(weatherCity.wind?.deg, forKey: "deg")
        itemWind.setValue(weatherCity.wind?.speed, forKey: "speed")

        item.setValue(itemWind, forKey: "wind")

        // Sys
        let itemSys = NSEntityDescription.insertNewObject(forEntityName: "WSys",
            into: minionManagedObjectContextWorker) as! WSys

        itemSys.setValue(weatherCity.sys?.id, forKey: "id")
        itemSys.setValue(weatherCity.sys?.sunrise, forKey: "sunrise")
        itemSys.setValue(weatherCity.sys?.sunset, forKey: "sunset")
        itemSys.setValue(weatherCity.sys?.country, forKey: "country")
        itemSys.setValue(weatherCity.sys?.type, forKey: "type")

        item.setValue(itemSys, forKey: "sys")

        // Clouds
        let itemClouds = NSEntityDescription.insertNewObject(forEntityName: "WClouds",
            into: minionManagedObjectContextWorker) as! WClouds

        itemClouds.setValue(weatherCity.clouds?.all, forKey: "all")

        item.setValue(itemClouds, forKey: "clouds")

        // Coord
        let itemCoord = NSEntityDescription.insertNewObject(forEntityName: "WCoord",
            into: minionManagedObjectContextWorker) as! WCoord

        itemCoord.setValue(weatherCity.coord?.lat, forKey: "lat")
        itemCoord.setValue(weatherCity.coord?.lon, forKey: "lon")

        item.setValue(itemCoord, forKey: "coord")

        // Weather
        if let weathers = weatherCity.weather {
            for weather: Weather in weathers {
                let itemWeather = NSEntityDescription.insertNewObject(forEntityName: "WWeather",
                    into: minionManagedObjectContextWorker) as! WWeather

                itemWeather.setValue(weather.id, forKey: "id")
                itemWeather.setValue(weather.icon, forKey: "icon")
                itemWeather.setValue(weather.main, forKey: "main")
                itemWeather.setValue(weather.weatherDescription, forKey: "weatherDescription")
                itemWeather.setValue(item, forKey: "weathercity")
            }
        }
        
        item.setValue(itemCoord, forKey: "coord")

        //Save current work on Minion workers
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)

        //Save and merge changes from Minion workers with Main context
        self.persistenceManager.mergeWithMainContext()

        //Post notification to update datasource of a given Viewcontroller/UITableView
        self.postUpdateNotification()
    }
    
    /**
        Retrieves all  items stored in the persistence layer, default (overridable)
        parameters:
        
        - Parameter sortedByDate: Bool flag to add sort rule: by Date
        - Parameter sortAscending: Bool flag to set rule on sorting: Ascending / Descending date.
    
        - Returns: Array<Weather> with found in datastore
    */
    func getAllCities(_ sortedByDate: Bool = true, sortAscending: Bool = true) -> Array<WWeatherCity> {
        var fetchedResults: Array<WWeatherCity> = Array<WWeatherCity>()

        // Create request on weather entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WWeatherCity")

        //Create sort descriptor to sort retrieved cities by Date, ascending
        if sortedByDate {
            let sortDescriptor = NSSortDescriptor(key: "name",
                ascending: sortAscending)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }

        //Execute Fetch request
        do {
            fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [WWeatherCity]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<WWeatherCity>()
        }

        return fetchedResults
    }

    /**
        Retrieve a city found by it's stored UUID.
    
        - Parameter cityId: UUID of  item to retrieve
        - Returns: Array of Found  items, or empty Array
    */
    func getCityById(_ cityId: Int) -> Array<WWeatherCity> {
        var fetchedResults: Array<WWeatherCity> = Array<WWeatherCity>()

        // Create request on city entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WWeatherCity")

        //Add a predicate to filter by cityId
        let findByIdPredicate =
        NSPredicate(format: "id = %i", cityId)
        fetchRequest.predicate = findByIdPredicate

        //Execute Fetch request
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) as! [WWeatherCity]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<WWeatherCity>()
        }

        return fetchedResults
    }

    /**
        Update  item for specific keys.
        
        - Parameter itemToUpdate: City the passed city to update it's member fields
        - Parameter itemDetails: Dictionary<String,AnyObject> the details to be updated
        - Returns: Void
    */
    func updateCity(_ itemToUpdate: WWeatherCity, itemDetails: Dictionary<String, AnyObject>) {

        let minionManagedObjectContextWorker: NSManagedObjectContext =
        NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance

        //Assign field values
        for (key, value) in itemDetails {
            itemToUpdate.setValue(value, forKey: key)
        }

        //Persist new City to datastore (via Managed Object Context Layer).
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        self.persistenceManager.mergeWithMainContext()

        self.postUpdateNotification()
    }

    // MARK: Delete

    /**
        Delete all  items from persistence layer.
   
        - Returns: Void
    */
    func deleteAllCities() {
        let retrievedItems = getAllCities()

        //Delete all city items from persistance layer
        for item in retrievedItems {
            self.mainContextInstance.delete(item)
        }
        
        //Save and merge changes from Minion workers with Main context
        self.persistenceManager.mergeWithMainContext()
        
        //Post notification to update datasource of a given Viewcontroller/UITableView
        self.postUpdateNotification()
    }

    /**
        Delete a single  item from persistence layer.
        
        - Parameter cityItem: Ecity to be deleted
        - Returns: Void
    */
    func deleteCity(_ item: WWeatherCity) {
        print(item)
        //Delete city item from persistance layer
        self.mainContextInstance.delete(item)
        
        //Save and merge changes from Minion workers with Main context
        self.persistenceManager.mergeWithMainContext()
        
        //Post notification to update datasource of a given Viewcontroller/UITableView
        self.postUpdateNotification()
    }

    /**
        Post update notification to let the registered listeners refresh it's datasource.
    
        - Returns: Void
    */
    fileprivate func postUpdateNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateCityTableData"), object: nil)
    }

}
