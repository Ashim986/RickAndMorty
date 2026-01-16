//
//  Service.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

protocol API {
    func searchCharacters(name: String) async throws -> SearchResponse
}

protocol ServiceProvidable: API, NetworkService { }

struct Service: ServiceProvidable {
    var networkClient = NetworkClient(baseURL: .baseURL)

    func searchCharacters(name: String) async throws -> SearchResponse {
        try await get(route: .route, param: [.name: name])
    }
}

extension String {
    static let baseURL = "https://rickandmortyapi.com"
    static let route = "/api/character"
    static let name = "name"
}
