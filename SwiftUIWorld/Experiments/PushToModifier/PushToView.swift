//
//  PushToView.swift
//  SwiftUIWorld
//
//  Created by Arnaud Nommay on 08/10/2024.
//

import SwiftUI

import SwiftUI

struct PushToView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Push to top
            Text("Top Aligned")
                .font(.subheadline)
                .pushTo(.top)

            // Push to left
            Text("Left Aligned")
                .font(.largeTitle)
                .pushTo(.left)


            // Center horizontally
            Text("Center Horizontally")
                .font(.title)
                .pushTo(.centerHorizontal)

            // Center vertically
            Text("Center Vertically")
                .font(.title)
                .pushTo(.centerVertical)
            
            // Push to right
            Text("Right Aligned")
                .font(.headline)
                .pushTo(.right)

            // Push to bottom
            Text("Bottom Aligned")
                .font(.subheadline)
                .pushTo(.bottom)
        }
        .padding()
    }
}

#Preview {
    PushToView()
}
