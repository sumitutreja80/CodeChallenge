//
//  SearchCityInterface.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

// Presenter
protocol SearchCityPresenting: class {
    var router: SearchCityRouting? { get set }
    var interactor: SearchCityInteracting? { get set }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    func handleSearchTap()
}


// Interactor
protocol SearchCityInteracting : class {
    func loadData(_ vmO: WeatherOutput, completion: @escaping (Decodable?, Error?) -> ())
    func stop()
    func loadFromDB() -> [WeatherCity]
}


// Router
protocol SearchCityRouting: class   {
    func navigate(to option: SearchCityNavigationOption)
}
enum SearchCityNavigationOption {
    case SearchCity
}


// View Controller
protocol SearchCityInterface: class {
    var presenter: SearchCityPresenting? { get set }
//    var tableDelegateDataSource: TableViewHelper? { get }
    func display(_ error: Error)
    func load(_ vm: WeatherResult)
}
