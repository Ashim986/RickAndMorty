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
            VStack(alignment: .leading) {
                CharacterImageView(url: character.image)
                .accessibilityLabel("\(character.name) image")

                Group {
                    infoRow(title: "Species", value: character.species)
                    infoRow(title: "Status", value: character.status)
                    infoRow(title: "Origin", value: character.origin.name)

                    if !character.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        infoRow(title: "Type", value: character.type)
                    }

                    infoRow(title: "Created", value: formattedCreatedDate)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedCreatedDate: String {
        guard let date = ISO8601DateFormatter().date(from: character.created) else {
            return character.created
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
