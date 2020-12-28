//
//  Requesting.swift
//  weather
//
//  Created by Utreja, Sumit on 18/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

let kBaseURLString = "http://api.openweathermap.org/"
let kPathURLString = "data/"
let kVersionURLString = "2.5/"
let kAPIURLString = "weather"

enum MethodType: String {
    case get = "GET"
    case post = "POST"
}

extension Dictionary {
    
    /// Returns JSON data from dictionary.
    var jsonData: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            print("Could not serialize value to raw data: \(error)")
        }
        
        return nil
    }
}


enum Parameters: Equatable {
    case body([String: Any])
    case rawBody(Data)
    case url([URLQueryItem])

    var queryItems: [URLQueryItem] {
        switch self {
        case .url(let urlParameters):
            return urlParameters
        default:
            return []
        }
    }

    var payloadRaw: [String: Any]? {
        switch self {
        case .body(let bodyDict):
            return bodyDict
        default:
            return nil
        }
    }
    
    var formData: Data? {
        switch self {
        case .rawBody(let raw):
            return raw
        default:
            return nil
        }
    }

    var formPayload: Data? {
        return formData
    }

    var payload: Data? {
        return payloadRaw?.jsonData
    }

    static func == (lhs: Parameters, rhs: Parameters) -> Bool {
        switch (lhs, rhs) {
        case (.body(let lhsA), .body(let rhsA)):
            return (lhsA as NSDictionary).isEqual(to: rhsA)
        case (.rawBody(let lhsA), .rawBody(let rhsA)):
            return lhsA == rhsA
        default:
            return false
        }
    }
}

protocol Requesting {
    
    /// The request body of the receiver.
    /// The request body which is sent as the message body of the request, as in an HTTP POST request.
    var parameters: Parameters? { get }
    
    /// HTTP method used for the request POST/GET.
    var method: MethodType { get }

    /// The url string for the request.
    var urlString: String { get }

    /// The URL of the receiver.
    /// Returns the URL for the request (with url components if .url parameters are provided).
    var url: URL? { get }

    /// A dictionary containing the HTTP header fields specific for the receiver.
    var requestHeaders: [String: Any] { get }

    /// The request body of the receiver.
    /// The request body which is sent as the message body of the request, as in an HTTP POST request.
    var body: Data? { get }
}

extension Requesting {
    /// Prepares the url with url components if any and also makes sure the HTTPMethod and parameter type matches
    var url: URL? {
        guard let queryItems = parameters?.queryItems, !queryItems.isEmpty, method == .get else {
            return URL(string: urlString)
        }

        guard var components = URLComponents(string: urlString) else {
            return nil
        }
        components.queryItems = queryItems
        return components.url
    }

    /// The request body of the receiver.
    /// The request body which is sent as the message body of the request, as in an HTTP POST request.
    /// Returns payload data provided as request parameter
    var body: Data? {
        guard method != .get else {
            return nil
        }
        
        return parameters?.payload
    }
}

/// Protocol to implement for each Request, which provides Equatable protocol implementation
protocol RequestingEquatable: Requesting, Equatable {
    
}

extension RequestingEquatable {
    
    /// By default compare the values of two Request objects for equality using their url and parameters.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.urlString == rhs.urlString
    }
    
}

public class BaseRequest: RequestingEquatable {
    var parameters: Parameters?

    /// The url string for the request.
    var urlString: String {
        return kBaseURLString + kPathURLString + kVersionURLString + kAPIURLString
    }

    var requestHeaders: [String : Any] {
        return [:]
    }
    
    var method: MethodType {
        return .get
    }
    
    required init() {
    }
}
