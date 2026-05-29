//
//  Card.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 22/05/2026.
//

import SwiftUI

struct Card: Identifiable, Equatable {
    let id = UUID()
    let holder: String
    let last4: String
    let network: String
    let gradient: [Color]
}

extension Card {
    static let samples: [Card] = [
        Card(holder: "ARNAUD NOMMAY",
             last4: "4242",
             network: "VISA",
             gradient: [.indigo, .purple]),
        Card(holder: "ARNAUD NOMMAY",
             last4: "8881",
             network: "MASTERCARD",
             gradient: [.orange, .pink]),
        Card(holder: "ARNAUD NOMMAY",
             last4: "1003",
             network: "AMEX",
             gradient: [.black, Color(.systemGray)]),
        Card(holder: "ARNAUD NOMMAY",
             last4: "7766",
             network: "CB",
             gradient: [.blue, .cyan]),
        Card(holder: "ARNAUD NOMMAY",
             last4: "9090",
             network: "APPLE PAY",
             gradient: [Color(.systemGray2), Color(.systemGray5)]),
    ]
}
