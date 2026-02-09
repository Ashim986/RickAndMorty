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

// MARK: - Generic Fetch

extension URLSession {
    func fetch<T: Decodable>(_ endpoint: some Endpoint & RequestBuilder) async throws -> T {
        let request = try endpoint.buildRequest()
        let (data, _) = try await self.data(for: request)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

// MARK: - Concrete Service

struct CharacterService: NetworkService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchCharacters(name: String) async throws -> [RMCharacter] {
        let response: SearchResponse = try await session.fetch(
            SearchCharacterEndpoint(name: name)
        )
        return response.results.map { $0.toDomain() }
    }
}
