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
            List {
                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.results) { character in
                            NavigationLink {
                                CharacterDetailView(character: character)
                            } label: {
                                CharacterRow(character: character)
                            }
                        }
                    }
                } header: {
                    TextField("Search by name…", text: $viewModel.query)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.vertical, 4)
                }
            }
            .listSectionHeaderTopPadding(0)
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
