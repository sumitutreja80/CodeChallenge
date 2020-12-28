//
//  SearchResultsInterface.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

// Presenter
protocol SearchResultsPresenting: class {
    var router: SearchResultsRouting? { get set }
    var interactor: SearchResultsInteracting? { get set }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    func handleCellSubViewTap(eventPayload: WeatherCityEvent)
    func handleBackButtonTap()
    func getCachedResponse() -> [WeatherResult]
    func fetchResults(_ searchText: String?)
}


// Interactor
protocol SearchResultsInteracting : class {
    func loadData(_ vmO: WeatherOutput,  completion: @escaping (Decodable?, Error?) -> ())
    func loadData(completion: @escaping (Decodable?, Error?) -> ())
    func stop()
    func getDBData() -> [WeatherCity]
    func saveAsFav2DB(_ cityId: Int)
    func saveCityObjectToDB(_ weatherCity: WeatherCity)
}


// Router
protocol SearchResultsRouting: class   {
    func navigate(to option: SearchResultsNavigationOption)
}
enum SearchResultsNavigationOption {
    case BackToSearch
}


// View Controller
protocol SearchResultsInterface: class {
    var presenter: SearchResultsPresenting? { get set }
//    var tableDelegateDataSource: TableViewHelper? { get }
    func display(_ error: Error)
    func load(_ vm: WeatherResult)
}
