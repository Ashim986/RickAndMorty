//
//  RequestBuilder.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

// MARK: - Request Builder Protocol

protocol RequestBuilder {
    func buildRequest() throws -> URLRequest
}

// MARK: - Default Implementation for any Endpoint

extension RequestBuilder where Self: Endpoint {
    func buildRequest() throws -> URLRequest {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}
