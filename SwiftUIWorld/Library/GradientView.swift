//
//  GradientView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 07/03/2023.
//

import SwiftUI

struct GradientView: View {
    var body: some View {
        ScrollView() {
            Rectangle()
                .fill(.blue.gradient)
                .frame(height: 200)
            
            RoundedRectangle(cornerRadius: 9)
                .fill(LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow]), startPoint: .leading, endPoint: .trailing))
                .frame(height: 200)

            
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple]), center: .center, startRadius: 50, endRadius: 100)
                )
                .frame(width: 200, height: 200)
            
            Circle()
                .fill(
                    AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
                )
                .frame(width: 200, height: 200)
        }
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView()
    }
}
