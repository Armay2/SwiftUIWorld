//
//  LottiesView.swift
//  SwiftUIWorld
//
//  Created by Arnaud Nommay on 17/12/2024. Wind
//

import SwiftUI
import Lottie

struct LottiesView: View {
    var body: some View {
        VStack() {
            Spacer()
            LottieView {
                try await DotLottieFile.named("MapLoader")
            }
            .looping()

            Spacer()

            LottieView {
                try await DotLottieFile.named("Wind")
            }
            .looping()

            Spacer()
        }
    }
}

#Preview {
    LottiesView()
}
