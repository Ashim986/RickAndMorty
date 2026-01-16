//
//  DataLoader.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
import Foundation

func loadData<T: Decodable>(from fileName: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        fatalError("Couldn't find \(fileName) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(file) from main bundler: \n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        let jsonData = try decoder.decode(T.self, from: data)
        return jsonData
    } catch {
        fatalError("Couldn't parse \(fileName) as \(T.self): \n\(error)")
    }

}
