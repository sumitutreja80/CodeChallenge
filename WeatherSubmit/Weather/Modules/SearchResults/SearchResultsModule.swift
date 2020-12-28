//
//  PresenterInterface.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsModule {
    class func buildDefault() -> UIViewController? {
        
        if let view = mainStoryboard.instantiateViewController(withIdentifier: "SearchResults") as? SearchResultsViewController {

            let interactor = SearchResultsInteractor <WeatherCityCommand<WeatherCity, WeatherCityRequest>> ()
            let presenter = SearchResultsPresenter()
            let router = SearchResultsRouter(viewController: view)
            
            view.presenter = presenter
            
            presenter.interactor = interactor
            presenter.view = view
            presenter.router = router
            
            interactor.presenter = presenter
            
            router.presenter = presenter
            
            return view
        }
        return UIViewController()
    }

    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }

}
