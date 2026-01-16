//
//  MockService.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
@testable import RickAndMorty

class MockService: ServiceProvidable {
    var networkClient: NetworkClient {
        return NetworkClient(baseURL: "")
    }

    var result: Result<SearchResponse, Error>?

    func searchCharacters(name: String) async throws -> SearchResponse {
        switch result {
            case .success(let success):
                return success
            case .failure(let failure):
                throw failure
            case nil:
                return SearchResponse(results: [])
        }
    }
}
