//
//  SearchCityRouter.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//
import Foundation

class SearchCityRouter:  BaseRouter {
    weak var presenter: SearchCityPresenting?

}
extension SearchCityRouter: SearchCityRouting {
    func navigate(to option: SearchCityNavigationOption ) {
        switch option {
        case .SearchCity:
            openSearchResults()
            break
        }
    }

    private func openSearchResults() {
        guard let vc = SearchResultsModule.buildDefault() else {
                   print("Error during module initialization")
                   return }
        if let router = (vc as! SearchResultsViewController).presenter?.router {
            self.navigationController?.pushRouter(router as! BaseRouter)
        }
    }
    
}
