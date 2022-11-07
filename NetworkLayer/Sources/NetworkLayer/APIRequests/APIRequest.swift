//
//  APIRequest.swift
//  
//
//  Created by Mohsen Qaysi on 19/04/2022.
//

import Foundation

public protocol APIRequest {
    associatedtype ResponseType: Decodable

    var acceptableResponseCodes: [HTTPStatusCode] { get }

    var cachePolicy: NSURLRequest.CachePolicy { get }
    var endpoint: String { get }
    var queryItems: [URLQueryItem] { get }
    func generateURLRequest() throws -> URLRequest
}


extension APIRequest {

    private var urlBase: String {
        return "https://s3.amazonaws.com/sq-mobile-interview"
    }

    fileprivate func createURL() throws -> URL {
        var components = URLComponents(string: urlBase + endpoint)
        components?.queryItems = queryItems // add queryItems if we have them

        guard let validComponents = components, let url = validComponents.url else {
            throw APIError.invalidUrl
        }

        return url
    }

    public var cachePolicy: NSURLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    public var queryItems: [URLQueryItem] {
        return []
    }
}

/*
 * GetAPIRequest
 *
 * This protocol outlines the basic requirements of any GET request
 */

protocol GetAPIRequest: APIRequest {}

extension GetAPIRequest {
    public var acceptableResponseCodes: [HTTPStatusCode] {
        return [.ok]
    }

    public func generateURLRequest() throws -> URLRequest {
        let url = try createURL()
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 60)
        request.httpMethod = "GET"
        request.setValue("en_GB", forHTTPHeaderField: "Accept-Language") // we can make this part dynamic
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
