//
//  NetworkClient+Data.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
import Foundation

extension NetworkClient {
    func get(route: String, param: Param) async throws -> Data {
        try await get(route: route, param: param).execute()
    }

    func post(route: String, param: Param) async throws -> Data {
        try await post(route: route, param: param).execute()
    }

}
