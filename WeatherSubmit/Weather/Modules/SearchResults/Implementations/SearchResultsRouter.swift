//
//  SearchResultsRouter.swift
//  weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
class SearchResultsRouter : BaseRouter {
    weak var presenter: SearchResultsPresenting?

}
extension SearchResultsRouter: SearchResultsRouting {
    func navigate(to option: SearchResultsNavigationOption ) {
        switch option {
        case .BackToSearch:
            self.backToSearch()
            break
        }
    }

    func backToSearch() {
        self.popFromNavigationController(animated: true)
    }
}
