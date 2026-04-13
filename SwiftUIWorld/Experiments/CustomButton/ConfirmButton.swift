//
//  ConfirmButton.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 26/02/2026.
//

import SwiftUI

struct ConfirmButton: View {
    @State var isConfirmationShown: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            buttonPressed()
        } label: {
            Image(systemName: isConfirmationShown ? "stop.circle.fill" : "stop.circle")
                .resizable()
                .frame(width: 50, height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func buttonPressed() {
        if isConfirmationShown {
            action()
        }
        isConfirmationShown.toggle()
    }
}

#Preview {
    ConfirmButton(action: {
        print("Button action!")
    })
}
