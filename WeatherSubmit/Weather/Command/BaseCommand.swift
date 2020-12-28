//
//  BaseCommand.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

protocol BaseCommand: class {
    var requestIDentifier : String? { get set }
    var progressMessage : String? { get set }

    init()    
}

extension BaseCommand {
    func startCommand() {
        DispatchQueue.main.async {
            if let _ = self.progressMessage {
            }
        }
    }
    
    func endCommand() {
        DispatchQueue.main.async {
        }
    }
}

extension BaseCommand {
    @discardableResult
    public func executeTask<T: Decodable, B: BaseRequest>(request: B, type:T.Type,
                                   completion: @escaping( _ object :T? , Error?) -> ()) -> (String) {
        
        return self.requestIDentifier ?? "TODO: Some ID"
    }
}
