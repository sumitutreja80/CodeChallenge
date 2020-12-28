//
//  WeatherCityCommand.swift
//  weather
//
//  Created by Utreja, Sumit on 19/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

class WeatherCityCommand<T : Decodable, R : RequestingEquatable> : ConcurrentOperation, BaseCommand {
    private var responseCompletionBlock: ((T?, Error?) -> ())? = nil
    private var request: R? = nil
    
    @discardableResult
    public func executeTask(request: R, type: T.Type, completion: @escaping (T?, Error?) -> ()) -> (String) {
        self.request = request
        self.responseCompletionBlock = completion
        addToSharedQueue(qos: .background)
        return self.requestIDentifier ?? "TODO: Some ID"
    }

    var requestIDentifier: String?
    
    var progressMessage: String?
    
    override open func main() {
        guard let req = self.request else {
            return
        }
        let repo = WeatherCityRepository.init(with: req as! WeatherCityRepository.R)
        repo.get(forRequest: req as! WeatherCityRepository.R,
                 completion: { (cityResponse, error) in
                    if let resp = self.responseCompletionBlock {
                        resp(cityResponse as? T, error)
                    }
                    self.finish()
        })
    }

    required override init() {
        super.init()
    }
}
