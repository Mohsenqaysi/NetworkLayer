//
//  CombineAPIClient.swift
//  
//
//  Created by Mohsen Qaysi on 19/04/2022.
//

import Combine
import Foundation

public protocol CombineAPISession {
    func apiDataTaskPublisher(with request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
}

extension URLSession: CombineAPISession {
    public func apiDataTaskPublisher(with request: URLRequest) -> AnyPublisher<DataTaskPublisher.Output, URLError> {
        return dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

public struct APIClientEmptyResponse: Decodable {}

public protocol CombineAPIClient {
    init(session: CombineAPISession?)
    func execute<T: APIRequest>(_ request: T) -> AnyPublisher<T.ResponseType, Error>
    func execute<T: APIRequest>(_ request: T, queue: DispatchQueue) -> AnyPublisher<T.ResponseType, Error>
}

extension JSONDecoder.DateDecodingStrategy {

    static let apiDecodingStrategy = custom {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = formatter.date(from: string) {
            return date
        }
        //if we want to support more formats, we just add them here, before throwing an error
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

public struct KitCombineAPIClient: CombineAPIClient {

    private let session: CombineAPISession?

    public init(session: CombineAPISession? = nil) {
        self.session = session
    }

    public func execute<T: APIRequest>(_ request: T) -> AnyPublisher<T.ResponseType, Error> {
        return execute(request, queue: .main)
    }

    public func execute<T: APIRequest>(_ request: T, queue: DispatchQueue) -> AnyPublisher<T.ResponseType, Error> {

        var concreteRequest: URLRequest
        do {
            concreteRequest = try request.generateURLRequest()
        } catch let error {
            return AnyPublisher(Fail(outputType: T.ResponseType.self, failure: error))
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .apiDecodingStrategy

        let apiSession = session ?? URLSession.shared
        return apiSession.apiDataTaskPublisher(with: concreteRequest)
            .tryMap {
                guard $0.response.mimeType == "application/json" else {
                    throw APIError.invalidResponseType
                }
                guard let dataResponse = $0.response as? HTTPURLResponse, let status = dataResponse.status else {
                    throw APIError.invalidResponseType
                }

                if request.acceptableResponseCodes.contains(status) {
                    if let response = APIClientEmptyResponse() as? T.ResponseType {
                        return response
                    }
                    do {
                        let result = try jsonDecoder.decode(T.ResponseType.self, from: $0.data)
                        return result
                    } catch let error {
                        throw error
                    }
                } else {
                    throw NSError(domain: "CombineAPIClient", code: status.rawValue, userInfo: nil)
                }
            }
            .mapError({ (error) -> Error in
                guard error as? APIError == nil else {
                    return error
                }
                let converted = error as NSError
                if [NSURLErrorNotConnectedToInternet, NSURLErrorCannotFindHost, NSURLErrorTimedOut].contains(converted.code) {
                    return APIError.deviceOffline
                }
                return APIError.invalidJson
            })
            .subscribe(on: DispatchQueue.global())
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}
