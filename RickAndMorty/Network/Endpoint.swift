//
//  Endpoint.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

// MARK: - Endpoint Protocol

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
}

// MARK: - Default base URL for Rick and Morty API

extension Endpoint {
    var baseURL: String { "https://rickandmortyapi.com" }
    var method: String { "GET" }
    var queryItems: [URLQueryItem] { [] }
}

// MARK: - Character Endpoints

struct SearchCharacterEndpoint: Endpoint {
    let name: String
    var path: String { "/api/character" }
    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "name", value: name)]
    }
}
