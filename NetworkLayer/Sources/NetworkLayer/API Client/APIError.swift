//
//  APIError.swift
//  
//
//  Created by Mohsen Qaysi on 19/04/2022.
//

import Foundation

public enum APIError: Error {
    case invalidUrl
    case invalidRequest
    case invalidResponseType
    case invalidResponseData
    case invalidJson
    case deviceOffline
    case errorCodeTypeMismatch
    case invalidAcceptableResponseCodes
    case urlSessionError
    case unknownError
}
