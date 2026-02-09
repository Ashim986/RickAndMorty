//
//  MockService.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
@testable import RickAndMorty

class MockService: NetworkService {
    var result: Result<[RMCharacter], Error> = .success([])

    func searchCharacters(name: String) async throws -> [RMCharacter] {
        try result.get()
    }
}
