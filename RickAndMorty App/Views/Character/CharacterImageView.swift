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
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            placeholder 
        }
        .clipped()
    }


    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
            ProgressView()
        }
    }
}

