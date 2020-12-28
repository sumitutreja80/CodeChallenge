//
//  SearchCityViewController.swift
//  weather
//
//  Created by Utreja, Sumit on 20/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

class TableCell: UITableViewCell {
    
}

private enum Cell {
    typealias Model = WeatherResult
    
    case cell(Model)
}

private struct AggregateConfigurator: ConfiguratorType {
    func registerCells(in tableView: UITableView) {
        cellConfigurator.registerCells(in: tableView)
    }
    
    let cellConfigurator: Configurator<WeatherResult, SearchResultHeader>
    
    func reuseIdentifier(for item: Cell, indexPath: IndexPath) -> String {
        switch item {
        case .cell:
            return cellConfigurator.reuseIdentifier
        }
    }

    func configuredCell(for item: Cell, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .cell(let model):
            return cellConfigurator.configuredCell(for: model, tableView: tableView, indexPath: indexPath)
        }
    }
}

class SearchCityViewController: UIViewController {

    var presenter: SearchCityPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        self.buildView()
        self.showLoading()
        self.loadview()
        self.presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.showLoading()
        self.presenter?.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterNotification()
        self.presenter?.viewDidDisappear()
    }
    
    /// Load data for the view
    ///
    /// - Parameter : recent - Fetch recent data from network or Old data from cache
    /// - Returns: Void
    private func loadData(recent: Bool) {
    }
    
    
    /// Load data from cache
    ///
    /// - Parameter : Void
    /// - Returns: Void
    func loadview() {
        self.loadData(recent: false)
    }
    
    /// The function should contain stuff with respect to creation or building view or
    /// sub views
    /// You can invoke functions of other classes, but currently the design doesn't support
    /// async calls.
    ///
    /// - Parameter : Void
    /// - Returns: Void
    private func buildView() {
        self.addLeftBarButtonItemsForSearch(#selector(search))
    }

    @objc func search(_ sender: UIButton) {
        self.presenter?.handleSearchTap()
    }


    /// Show the activity indicator on the main view
    ///
    /// - Parameter : Void
    /// - Returns: Void
    private func showLoading() {
        DispatchQueue.main.async {
        }
    }

    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .ReachabilityDidChange, object: nil)
    }
    
    private func deregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: .ReachabilityDidChange, object: nil)
    }
    
    @objc func reachabilityChanged(_ notification: Notification?) {
        // give alert that you are in offline.
        DispatchQueue.main.async {
            let hasNetwork = NetworkReachability.isNetworkAvailable
            if !hasNetwork {
//                self.displayalert(title: "Netrwork Issue", message: "Seems you are offline. Please check your network connection")
            } else {
                // back online.
                self.displayalert(title: "Great", message: "You are back online")
            }
        }
    }

}

extension SearchCityViewController: SearchCityInterface {
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
        DispatchQueue.main.async {
//                self.stopAnimation()
            let section0 = Section<Cell>(items: [.cell(vm)])
            let dataSource = DataSource(sections: [section0])
              
            let configurator1 = Configurator { (cell, model: WeatherResult, tableView, indexPath) -> SearchResultHeader in
                cell.mainDesc.text = model.name
                cell.currentTemp.text = self.formattedTemperature(String(format: "%.2f &deg", model.currTemp ?? 0.0))
                return cell
            }
              
            let aggregate = AggregateConfigurator(cellConfigurator: configurator1)

            let table = BaseTableViewController(dataSource: dataSource, configurator: aggregate)

            self.add(child: table, container: self.view)
        }
    }
}
