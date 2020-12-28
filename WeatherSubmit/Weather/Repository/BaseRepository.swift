//
//  BaseRepository.swift
//  weather
//
//  Created by Utreja, Sumit on 19/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

// MARK: Repository
protocol IRepository {
    associatedtype T: Decodable
    associatedtype R: RequestingEquatable

    func get(completion: @escaping (T?, Error?) -> ()) -> String
}

extension IRepository {
    @discardableResult
    func get(forRequest: R, completion: @escaping (T?, Error?) -> ()) -> String {
        return NetworkServices().executeRequest(with: forRequest, forDecodableType: T.self)
        { (decodableData: T?, error) in
            completion(decodableData, error)
        }
    }
}
