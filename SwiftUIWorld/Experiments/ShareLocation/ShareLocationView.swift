//
//  ShareAddress.swift
//  SwiftUIWorld
//
//  Created by Arnaud Nommay on 04/12/2024.
//

import SwiftUI

import SwiftUI

struct ShareLocationView: View {
    let latitude = 48.8566   // Exemple: Latitude de Paris
    let longitude = 2.3522  // Exemple: Longitude de Paris

    var body: some View {
        VStack {
            Text("Partager les coordonnées GPS")
                .font(.headline)

            ShareLink(
                item: shareURL,
                preview: SharePreview("Ouvrir la localisation", image: Image(systemName: "map"))
            ) {
                Label("Partager la position", systemImage: "square.and.arrow.up")
            }
            .padding()
        }
    }

    /// Génère une URL partageable
    var shareURL: URL {
        let appleMapsURL = URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)")!
        return appleMapsURL
    }
}

#Preview {
    ShareLocationView()
}
