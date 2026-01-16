//
//  NetworkService.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
import Foundation

protocol NetworkService {
    var networkClient: NetworkClient { get }
}

extension ServiceProvidable {
    func get(route: String, param: Param) async throws -> Data {
        try await networkClient.get(route: route, param: param)
    }

    func get<T: Decodable>(route: String, param: Param) async throws -> T {
        try await networkClient.get(route: route, param: param)
    }
}
