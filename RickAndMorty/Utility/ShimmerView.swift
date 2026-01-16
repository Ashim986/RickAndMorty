//
//  ShimmerView.swift
//  RickAndMorty
//
//  Created by ashim Dahal on 1/15/26.
//

import SwiftUI
    // MARK: - Shimmer

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(stops: [
                    .init(color: .white.opacity(0.0), location: 0),
                    .init(color: .white.opacity(0.35), location: 0.5),
                    .init(color: .white.opacity(0.0), location: 1)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .rotationEffect(.degrees(0))
                .offset(x: phase)
                .mask(content)
            }
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 240
                }
            }
    }
}

extension View { func shimmer() -> some View { modifier(ShimmerModifier()) } }


struct SkeletonGrid: View {
    var rows: Int = 2
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            let range = 0..<rows
            ForEach(range, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
                    .frame(height: 240)
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.6)).frame(height: 16)
                            RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.3)).frame(height: 12)
                            HStack {
                                ForEach(0..<5) { _ in Circle().fill(.white.opacity(0.5)).frame(width: 8, height: 8) }
                            }.padding(.bottom, 8)
                        }
                            .padding(12)
                    )
                    .shimmer()
            }
        }
        .padding(.horizontal)
    }
}
