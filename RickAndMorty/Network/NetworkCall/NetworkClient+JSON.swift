//
//  NetworkClient+Json.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation

extension NetworkClient {
    // implement for json object
    func get<T: Decodable>(route: String, param: Param) async throws -> T {
        try await get(route: route, param: param).toJSON()
    }
}


extension Data {
    func toJSON<T: Decodable>() throws -> T {
        let decoder = JSONDecoder()
        let json = try decoder.decode(T.self, from: self)
        return json
    }
}
