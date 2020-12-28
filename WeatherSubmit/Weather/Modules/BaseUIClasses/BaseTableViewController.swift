//
//  BaseTableViewController.swift
//  weather
//
//  Created by Utreja, Sumit on 21/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

class BaseTableViewController<Configurator: ConfiguratorType>: UITableViewController {
    
    let dataSource: DataSource<Configurator.Item>
    let configurator: Configurator
    
    init(dataSource: DataSource<Configurator.Item>, configurator: Configurator) {
        self.dataSource = dataSource
        self.configurator = configurator
        super.init(nibName: nil, bundle: nil)
        configurator.registerCells(in: tableView)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataSource.item(at: indexPath)
        return configurator.configuredCell(for: item, tableView: tableView, indexPath: indexPath)
    }
}
