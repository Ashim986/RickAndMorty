//
//  Character.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

struct SearchResponse: Decodable {
    let results: [RMCharacter]
}

struct RMCharacter: Decodable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let image: URL
    let created: String
    let origin: Origin

    struct Origin: Decodable {
        let name: String
    }
}
