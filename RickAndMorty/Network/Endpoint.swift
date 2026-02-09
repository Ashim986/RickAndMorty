//
//  Endpoint.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

// MARK: - Endpoint Protocol (Factory Pattern)

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
}

// MARK: - Character Endpoint (Concrete Factory)

enum CharacterEndpoint: Endpoint {
    case search(name: String)

    var baseURL: String { "https://rickandmortyapi.com" }

    var path: String {
        switch self {
        case .search: return "/api/character"
        }
    }

    var method: String { "GET" }

    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let name):
            return [URLQueryItem(name: "name", value: name)]
        }
    }
}
