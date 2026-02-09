//
//  SearchCharacterViewModel.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import Foundation
import Combine

class SearchCharacterViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var results: [RMCharacter] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let service: NetworkService
    private var cancellable = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(service: NetworkService = CharacterService()) {
        self.service = service
        bindSearch()
    }

    func bindSearch() {
        $query
            .dropFirst()
            .map{ $0.trimmingCharacters(in: .whitespaces)}
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { query in
                self.performSearch(query)
            }
            .store(in: &cancellable)
    }

    func performSearch(_ query: String) {
            // cancel previous task
        searchTask?.cancel()

        guard !query.isEmpty else {
            results = []
            errorMessage = nil
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil 

        // receive data in main thread
        searchTask = Task { @MainActor in
            do {
                let characters = try await service.searchCharacters(name: query)

                if !Task.isCancelled {
                    self.results = characters
                    errorMessage = nil
                }

            } catch let err as NetworkError {
                errorMessage = err.localizedDescription
                self.results = []

            } catch {
                errorMessage = "Something went wrong"
                self.results = []
            }

            isLoading = false
        }
    }
}
