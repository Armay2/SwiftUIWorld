//
//  CardView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 22/05/2026.
//

import SwiftUI

struct CardView: View {
    let card: Card

    var body: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: card.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(1.586, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                Image(systemName: "wave.3.right")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(20)
            }
            .overlay(alignment: .topTrailing) {
                Text(card.network)
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(20)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("•••• •••• •••• \(card.last4)")
                        .font(.system(.title3, design: .monospaced, weight: .semibold))
                    Text(card.holder)
                        .font(.caption.bold())
                        .tracking(1)
                }
                .foregroundStyle(.white)
                .padding(20)
            }
            .shadow(color: .black.opacity(0.2), radius: 6, y: 4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(card.network) card ending in \(card.last4), \(card.holder)")
    }
}

#Preview {
    CardView(card: Card.samples[0])
        .padding()
}
