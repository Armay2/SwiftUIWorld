//
//  MaskView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

struct MaskView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 9.0)
            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .leading, endPoint: .trailing))
        .mask {
            Text("THIS IS A MASK")
                .font(.largeTitle)
                .bold()
        }
    }
}

struct MaskView_Previews: PreviewProvider {
    static var previews: some View {
        MaskView()
    }
}
