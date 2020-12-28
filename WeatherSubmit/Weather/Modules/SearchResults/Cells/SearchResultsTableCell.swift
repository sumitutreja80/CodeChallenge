//
//  SearchResultsTableCell.swift
//  Weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsTableCell: UITableViewCell {

    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var currTemp: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var eventEmitter: BaseEventEmitter? = nil
    
    var viewModel : WeatherResult?
        
    @IBAction func favButtonTap() {
        let event: WeatherCityEvent = .kEventRequestedFor(cityId: viewModel?.cityId)
        eventEmitter?.notify(eventPayload: ["userClick": event])

    }
}
