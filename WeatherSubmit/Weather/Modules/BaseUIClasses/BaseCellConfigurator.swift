//
//  BaseCellConfigurator.swift
//  weather
//
//  Created by Utreja, Sumit on 21/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

protocol ConfiguratorType {
    associatedtype Item
    associatedtype Cell: UITableViewCell
    
    func reuseIdentifier(for item: Item, indexPath: IndexPath) -> String
    func registerCells(in tableView: UITableView)
    func configuredCell(for item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell
}

struct Configurator<Item, Cell: UITableViewCell>: ConfiguratorType {
    typealias CellConfigurator = (Cell, Item, UITableView, IndexPath) -> Cell
    
    let configurator: CellConfigurator
    let reuseIdentifier = "\(Cell.self)"
    
    func reuseIdentifier(for item: Item, indexPath: IndexPath) -> String {
        return reuseIdentifier
    }
    
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
        return configurator(cell, item, tableView, indexPath)
    }
    
    func registerCells(in tableView: UITableView) {
        if let path = Bundle.main.path(forResource: "\(Cell.self)", ofType: "nib"),
            FileManager.default.fileExists(atPath: path) {
            let nib = UINib(nibName: "\(Cell.self)", bundle: .main)
            tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        } else {
            tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
        }
    }

    func configuredCell(for item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
            let reuseIdentifier = self.reuseIdentifier(for: item, indexPath: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
            return self.configure(cell: cell, item: item, tableView: tableView, indexPath: indexPath)
    }
}
