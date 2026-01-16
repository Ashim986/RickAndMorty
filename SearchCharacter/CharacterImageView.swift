//
//  CharacterImageView.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import SwiftUI

struct CharacterImageView: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure(_): placeholder
                        case .empty: placeholder.shimmer()
                        @unknown default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CharacterImageView(url: URL(string: ""))
}
