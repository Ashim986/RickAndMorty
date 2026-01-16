//
//  NetworkClient.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
import Foundation

struct NetworkClient {
    let baseURL: String
    let timeInterval: TimeInterval?
    var headers: Param = [:]

    init(baseURL: String, timeInterval: TimeInterval? = nil) {
        self.baseURL = baseURL
        self.timeInterval = timeInterval
    }
}
