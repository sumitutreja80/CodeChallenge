//
//  NetworkServices.swift
//  weather
//
//  Created by Utreja, Sumit on 19/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

public typealias SuccessBlock = (Int?, Data?, URLResponse?) -> Void
public typealias FailureBlock = (Int?, Data?, Swift.Error?) -> Void
public typealias ProgressBlock = (Int?, UInt64?) -> Void

enum NetworkError: Error {
    case jsonParsingFailed
    case invalidResponse
    case invalidAPIKey
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .jsonParsingFailed:
            return NSLocalizedString("JSON", comment: "Parsing Failed")
        case .invalidResponse:
            return NSLocalizedString("Response", comment: "Invalid Response")
        case .invalidAPIKey:
            return NSLocalizedString("Response", comment: "Invalid API Key")
        }
    }
}
protocol BaseNetworkServices: class {
    var successBlock: SuccessBlock? { get set }
    var failureBlock: FailureBlock? { get set }
    var progressBlock: ProgressBlock? { get set }
    
    func parseResponse<T: Decodable>(with responseData: Data, decodingType: T.Type,
                                     completion: @escaping (_ Object: T?, Swift.Error?) -> Void)
}

extension BaseNetworkServices {
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func submitRequest<T: Decodable, R: RequestingEquatable>(with reqObject: R,
                                                             forDecodableType: T.Type,
                                                             completion: @escaping( _ object :T? , Error?) -> ()) -> (Void) {
        successBlock = { (status, data, response) in
            if let d = data {
                self.parseResponse(with: d, decodingType: forDecodableType) { (decodable, error) in
                    completion(decodable, error)
                }
            }
        }

        failureBlock = { (status, response, error) in
            if let s = status, s == 401, let data = response, let msg = String(data: data, encoding: String.Encoding.utf8) {
                if let dict = self.convertToDictionary(text: msg), dict.count > 0, dict.values.count > 0 {
                    if let _ = dict["message"], let val: String = (dict["message"] as? String) {
                        let contains = val.contains("Invalid API key")
                        if contains == true {
                            completion(nil, NetworkError.invalidAPIKey)
                        }
                    }
                }
            } else {
                // TODO : Show UI for no network.
            }
        }

        let op: URLOperation = URLOperation.init(req: reqObject as! BaseRequest)
        op.submitRequest(success: self.successBlock, failure: self.failureBlock,
                         progress: self.progressBlock)
    }
}

public class NetworkServices : BaseNetworkServices {
    var successBlock: SuccessBlock?
    var failureBlock: FailureBlock?
    var progressBlock: ProgressBlock?
    
    public func parseResponse<T>(with responseData: Data, decodingType: T.Type, completion: @escaping (T?, Error?) -> Void) where T : Decodable {
        print(String(decoding: responseData, as: UTF8.self))

        // Request is success but no data comes as response.
        if 0 == responseData.count {
            print("error")
            completion(nil, NetworkError.invalidResponse)
        }
        
        do {
            let parsedResponse: T = try JSONDecoder().decode(decodingType, from: responseData )
            completion(parsedResponse, nil)
        } catch let jsonError {
            print("JSON Parsing error description \(jsonError.localizedDescription)")
            completion(nil, NetworkError.jsonParsingFailed)
        }
    }

    func executeRequest<T, R>(with reqObject: R, forDecodableType: T.Type, completion: @escaping( _ object :T? , Error?) -> ()) -> (String) where T: Decodable, R: RequestingEquatable {
        (self as BaseNetworkServices).submitRequest(with: reqObject,
                                                    forDecodableType: forDecodableType,
                                                    completion: { (response, error) in
                                                        completion(response, error)
        })
        let requestIdentifier = ""
        return requestIdentifier
    }
}
