//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: RMCharacter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CharacterImageView(url: character.image)

                Group {
                    infoRow(title: "Species", value: character.species)
                    infoRow(title: "Status", value: character.status)
                    infoRow(title: "Origin", value: character.origin)

                    if !character.type.isEmpty {
                        infoRow(title: "Type", value: character.type)
                    }

                    infoRow(title: "Created", value: character.formattedDate)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                ShareLink(item: "\(character.name) - \(character.species) (\(character.status))")
            }
        })
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }
}
