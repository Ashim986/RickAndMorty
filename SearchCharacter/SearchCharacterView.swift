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
            VStack {
                searchBar

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.secondary)
                }

                if viewModel.isLoading {
                    List(0...4, id: \.self) { index in
                        SkeletonGrid(rows: index)
                    }
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
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search by name…", text: $viewModel.query)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.search)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
