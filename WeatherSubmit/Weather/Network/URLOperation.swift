//
//  URLOperation.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

public class URLOperation {
    private let lockQueue = DispatchQueue(label: "com.sumitweather.urloperation", attributes: .concurrent)

    private let reqObject: BaseRequest
    private var dataTask: URLSessionTask?
    private var _isCancelled: Bool = false
    private(set) var isCancelled: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isCancelled
            }
        }
        set {
            lockQueue.sync(flags: [.barrier]) {
                _isCancelled = newValue
            }
        }
    }

    public required init(req: BaseRequest) {
        self.reqObject = req
    }
    
    private func setupSessionConfig() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        return URLSession(configuration: sessionConfig)
    }

    public func submitRequest(success: SuccessBlock?, failure: FailureBlock?,
                       progress: ProgressBlock?) {
        let request = URLRequest(url: reqObject.url ?? URL.init(fileURLWithPath: reqObject.urlString))

        dataTask = setupSessionConfig().dataTask(with: request, completionHandler: {(data, response, error) in
            guard self.isCancelled == false else {
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("No valid response. May be no network")
                if let f = failure {
                    f((response as? HTTPURLResponse)?.statusCode, nil, error)
                }
                return
            }
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                if let f = failure {
                    f((response as? HTTPURLResponse)?.statusCode, data, error)
                }
               print("Status code was \(httpResponse.statusCode), but expected 2xx")
               return
           }

            if let err = error {
                if let f = failure {
                    f((response as? HTTPURLResponse)?.statusCode, data, err)
                }
                return
            }

            if let s = success {
                s((response as? HTTPURLResponse)?.statusCode, data, response)
            }
        })
        dataTask?.resume()
    }

    public func cancel() {
        dataTask?.cancel()
        isCancelled = true
    }
}
