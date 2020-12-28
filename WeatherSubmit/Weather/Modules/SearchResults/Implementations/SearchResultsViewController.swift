//
//  SearchResultsViewController.swift
//  weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var presenter: SearchResultsPresenting?
    fileprivate var resultSearchController: UISearchController?
    fileprivate var results: [WeatherResult] = []
    fileprivate var filteredResults: [WeatherResult] = []
    fileprivate let resultTableCellIdentifier = "resultCell"
    typealias EventEmitter = BaseEventEmitter
    var eventEmitter: BaseEventEmitter? = BaseEventEmitter(queueName: "SearchResults")

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToEvents()
        self.buildView()
        self.showLoading()
        refreshTableData()
        self.presenter?.viewDidLoad()
    }

    /**
        Refresh table data
        
        - Returns: Void
    */
    fileprivate func refreshTableData() {
        self.results.removeAll(keepingCapacity: false)
        results = self.presenter?.getCachedResponse() ?? []
        self.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.presenter?.viewDidDisappear()
    }
    
    /// The function should contain stuff with respect to creation or building view or
    /// sub views
    /// You can invoke functions of other classes, but currently the design doesn't support
    /// async calls.
    ///
    /// - Parameter : Void
    /// - Returns: Void
    
    private func buildView() {
//        self.addRightBarButtonItems(#selector(addFav))
//        let searchBar = UISearchBar()
//        self.navigationItem.titleView = searchBar
//        searchBar.becomeFirstResponder()
        initResultSearchController()
        self.addLeftBackButton(#selector(goBack))
    }

    /**
        Create a searchbar, bind it to tableview header
    
        - Returns: Void
    */
    fileprivate func initResultSearchController() {
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController?.searchResultsUpdater = self
        resultSearchController?.searchBar.sizeToFit()
        resultSearchController?.searchBar.delegate = self as UISearchBarDelegate

        self.tableView.tableHeaderView = resultSearchController?.searchBar
    }

    @objc func goBack() {
        self.presenter?.handleBackButtonTap()
    }
    
    @objc func addFav() {

    }

    /// Show the activity indicator on the main view
    ///
    /// - Parameter : Void
    /// - Returns: Void
    private func showLoading() {
        DispatchQueue.main.async {
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultSearchController?.searchBar.resignFirstResponder()
        if let txt = searchBar.text, txt.isEmpty == false {
            self.presenter?.fetchResults(txt)
        }

    }
    
    func updateSearchResults(for searchController: UISearchController) {
    }

}

extension SearchResultsViewController: SearchResultsInterface {
    func display(_ error: Error) {
        // stop activity indicators
        // show actual error...
        print("\(error.localizedDescription)")
        DispatchQueue.main.async {
//                self.stopAnimation()
        }
    }
    
    /// Request succesfully completed. Update UI.
    ///
    /// - Parameter : vm - ViewModel for the UI
    /// - Returns: Void
    func display() {
        DispatchQueue.main.async {
//                self.stopAnimation()
        }
        
        DispatchQueue.main.async {
        }
    }

    /// Request succesfully completed. Update UI.
    ///
    /// - Returns: Void
    func load(_ vm: WeatherResult) {
        self.results = [vm]
        DispatchQueue.main.async {
//                self.stopAnimation()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController?.isActive  ?? false {
            return self.results.count
        }

        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
        tableView.dequeueReusableCell(withIdentifier: resultTableCellIdentifier, for: indexPath) as! SearchResultsTableCell

        let item: WeatherResult!

        if resultSearchController?.isActive ?? false {
            item = results[(indexPath as NSIndexPath).row]
        } else {
            item = results[(indexPath as NSIndexPath).row]
        }
        cell.eventEmitter = self.eventEmitter
        cell.viewModel = self.results[indexPath.row]
        cell.name.text = item.name
        cell.currTemp.text = self.formattedTemperature(String(format: "%.2f &deg", item.currTemp ?? 0.0))

        return cell
    }

}

extension SearchResultsViewController {
    // MARK: EventEmitting Subscribing to events
    func subscribeToEvents() {
        self.eventEmitter?.subscribe { (payload) in
            let index = payload.index(payload.startIndex, offsetBy: 0)
            if let key = ((payload as [String: Any]).keys[index] as? String), let value = (payload as [String: Any])[key] as? WeatherCityEvent {
                // find the object from the results.
                self.presenter?.handleCellSubViewTap(eventPayload: value)
            }

        }
    }
}

