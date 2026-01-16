//
//  NetworkingRequest.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

class NetworkingRequest {
    var baseURL: String = ""
    var route: String = ""
    var header: Param = [:]
    var httpVerb: HTTPVerb = .get
    var param: Param = [:]
    var timeInterval: TimeInterval?


    func execute() async throws -> Data {
        guard let  request = buildRequest() else {
            throw NetworkingError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    func buildRequest() -> URLRequest? {
        var urlString = baseURL + route
        if httpVerb == .get {
            urlString = getURLWithPram()
        }

        guard let url = URL(string: urlString) else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpVerb.rawValue

        if let timeInterval {
            urlRequest.timeoutInterval = timeInterval
        }

        return urlRequest
    }

    func getURLWithPram() -> String {
        let urlString = baseURL + route

        guard let url = URL(string: urlString) else { return urlString }

        if var urlComponent = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) {

            var queryItems = urlComponent.queryItems ?? [URLQueryItem]()

            for (key, value) in param {
                queryItems.append(URLQueryItem(name: key, value: value))
            }

            urlComponent.queryItems = queryItems

            return urlComponent.url?.absoluteString ?? urlString
        }

        return urlString
    }

}

enum NetworkingError: LocalizedError {
    case badURLRequest(code: Int)
    case invalidURL
    case decodingFail
    case unknownServer
    case unknown

    var errorDescription: String {
        switch self {
            case .badURLRequest(let code): return "Server returned status code \(code)."
            case .invalidURL: return "Couldn’t build the request."
            case .decodingFail: return "Couldn’t read the server response."
            case .unknownServer: return "Server responded with unknown error"
            case .unknown: return "Unknown Error"
        }
    }


}
