//
//  Character.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

// MARK: - API Response

struct SearchResponse: Decodable {
    let results: [CharacterDTO]
}

// MARK: - DTO (matches API JSON)

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let image: URL
    let created: String
    let origin: OriginDTO

    struct OriginDTO: Decodable {
        let name: String
    }
}


// MARK: - Domain Model

struct RMCharacter: Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let image: URL
    let created: Date
    let origin: String

    var formattedDate: String {
        created.formatted(date: .abbreviated, time: .omitted)
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static func parseDate(_ string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }
}

extension RMCharacter {
    init(dto: CharacterDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            status: dto.status,
            species: dto.species,
            type: dto.type,
            image: dto.image,
            created: Self.parseDate(dto.created),
            origin: dto.origin.name
        )
    }
}
