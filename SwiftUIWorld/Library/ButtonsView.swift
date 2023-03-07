//
//  ButtonsView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

//TODO: Explain dif scroll with and without Vstack in it

struct ButtonsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("You create a button by providing an action and a label. The action is either a method or closure property that does something when a user clicks or taps the button. The label is a view that describes the button’s action — for example, by showing text, an icon, or both:")
                        
                Text("Default Apple style").font(.title)

                Button("Automatic style") {
                    //
                }.buttonStyle(.automatic)
                
                Button("Plain") {
                    //
                }.buttonStyle(.plain)
                
                Button("Bordered") {
                    //
                }.buttonStyle(.bordered)
                
                Button("BorderedProminent") {
                    //
                }.buttonStyle(.borderedProminent)
                
                Button("Borderless") {
                    //
                }.buttonStyle(.borderless)
                
                Button("BorderedProminent capsule") {
                    //
                }.buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                
                Button("BorderedProminent roundedRectangle") {
                    //
                }.buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                
                Button {
                    //
                } label: {
                    Text("Text").foregroundColor(.red)
                }
            }
        }.navigationTitle("Buttons")

    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
