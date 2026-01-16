//
//  CharacterRow.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//
import SwiftUI

struct CharacterRow: View {
    let character: RMCharacter

    var body: some View {
        HStack(spacing: 12) {

            CharacterImageView(url: character.image)
                .accessibilityHidden(true)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("\(character.name) image")
            VStack(alignment: .leading, spacing: 2) {
                Text(character.name)
                    .font(.headline)
                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
