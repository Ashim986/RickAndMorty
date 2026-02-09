//
//  NetworkService.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

// MARK: - Service Protocol (DI Contract)

protocol NetworkService {
    func searchCharacters(name: String) async throws -> [RMCharacter]
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Couldn't build the request."
        case .requestFailed: return "Request failed."
        case .decodingFailed: return "Couldn't read the server response."
        }
    }
}

// MARK: - Concrete Service

struct CharacterService: NetworkService {
    func searchCharacters(name: String) async throws -> [RMCharacter] {
        let request = try SearchCharacterEndpoint(name: name).buildRequest()
        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            return try JSONDecoder().decode(SearchResponse.self, from: data)
                .results.map { $0.toDomain() }
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
