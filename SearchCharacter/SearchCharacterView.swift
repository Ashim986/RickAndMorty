//
//  SearchCharacterView.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import SwiftUI

struct CharacterSearchView: View {
    @StateObject private var viewModel: SearchCharacterViewModel

    init(viewModel: SearchCharacterViewModel = SearchCharacterViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.secondary)
                } else {
                    List(viewModel.results) { character in
                        NavigationLink {
                            CharacterDetailView(character: character)
                        } label: {
                            CharacterRow(character: character)
                        }
                    }
                }
            }
            .navigationTitle("Characters")
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name…")
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
    }
}
