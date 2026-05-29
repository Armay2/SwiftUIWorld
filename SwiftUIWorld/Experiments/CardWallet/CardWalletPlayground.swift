//
//  CardWalletPlayground.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 22/05/2026.
//

import SwiftUI

struct CardWalletPlayground: View {
    @State private var selectedIndex = 0
    @ScaledMetric(relativeTo: .largeTitle) private var chevronSize: CGFloat = 44
    private let cards = Card.samples

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            WalletCarousel(items: cards, selectedIndex: $selectedIndex) { card in
                CardView(card: card)
            }

            Spacer()

            HStack(spacing: 24) {
                Button("Previous card", systemImage: "chevron.left.circle.fill", action: previousCard)
                    .labelStyle(.iconOnly)
                    .font(.system(size: chevronSize))

                Text("\(selectedIndex + 1) / \(cards.count)")
                    .font(.headline.monospacedDigit())
                    .frame(width: 80)

                Button("Next card", systemImage: "chevron.right.circle.fill", action: nextCard)
                    .labelStyle(.iconOnly)
                    .font(.system(size: chevronSize))
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Card Wallet")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func previousCard() {
        selectedIndex = (selectedIndex - 1 + cards.count) % cards.count
    }

    private func nextCard() {
        selectedIndex = (selectedIndex + 1) % cards.count
    }
}

#Preview {
    NavigationStack {
        CardWalletPlayground()
    }
}
