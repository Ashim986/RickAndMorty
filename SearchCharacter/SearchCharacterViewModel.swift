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

    private let service: ServiceProvidable
    private var cancellable = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(service: ServiceProvidable = Service() ) {
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

        // receive data in main thread
        searchTask = Task { @MainActor in
            do {
                let response = try await service.searchCharacters(name: query)

                if !Task.isCancelled {
                    self.results = response.results
                    errorMessage = nil 
                }

            } catch let err as NetworkingError {
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
