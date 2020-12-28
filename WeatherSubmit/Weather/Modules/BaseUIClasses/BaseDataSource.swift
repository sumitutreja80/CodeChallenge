//
//  BaseDataSource.swift
//  weather
//
//  Created by Utreja, Sumit on 21/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation


struct Section<Item> {
    var items: [Item]
}

struct DataSource<Item> {
    var sections: [Section<Item>]
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].items.count
    }
    
    func item(at indexPath: IndexPath) -> Item {
        return sections[indexPath.section].items[indexPath.row]
    }
}
