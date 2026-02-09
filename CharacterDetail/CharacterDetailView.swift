//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//


import SwiftUI


struct CharacterDetailView: View {
    let character: RMCharacter
    @State private var showShare = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                CharacterImageView(url: character.image)
                .accessibilityLabel("\(character.name) image")

                Group {
                    infoRow(title: "Species", value: character.species)
                    infoRow(title: "Status", value: character.status)
                    infoRow(title: "Origin", value: character.origin)

                    if !character.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        infoRow(title: "Type", value: character.type)
                    }

                    infoRow(title: "Created", value: character.formattedDate)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShare = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            let shareItems = [
                character.name,
                character.species,
                character.status,
                character.image
            ]
            ShareSheet(items: shareItems)
        }
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



struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
