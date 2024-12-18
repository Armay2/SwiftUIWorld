//
//  BlurView.swift
//  SwiftUIWorld
//
//  Created by Arnaud Nommay on 16/12/2024.
//

import SwiftUI
import MapKit

struct BlurView: View {
    var body: some View {
        ZStack {
            Map()
        }
        .blur(radius: 5)
    }
}

#Preview {
    BlurView()
}
