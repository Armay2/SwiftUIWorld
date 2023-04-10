//
//  ReflectiveUIView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI
import AVFoundation


struct Reflection: ViewModifier {
    
    func body(content: Content) -> some View {
        CameraView(postion: .back)
            .blur(radius: 8)
            .mask(
                content
            )
    }
    
}

extension View {
    func reflective() -> some View {
        modifier(Reflection())
    }
}

struct ReflectiveUIView: View {
    
    var body: some View {
        HStack() {
            myContent
                .reflective()
            Spacer()
        }
    }
    
    var myContent: some View  {
        VStack(alignment: .leading) {
            Text("My reflective list")
                .font(.largeTitle)
                .bold()
            Spacer()
            ForEach((1...7), id: \.self) { num in
                HStack {
                    Image(systemName: "\(num).circle.fill").resizable()
                        .frame(width: 30, height: 30)
                    VStack(alignment: .leading) {
                        Text("Hello, World! Longer version").redacted(reason: .placeholder)
                        Text("Hello, World!").redacted(reason: .placeholder)
                    }
                }.padding()
            }
            Spacer()
        }
    }
}

struct ReflectiveUIView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectiveUIView()
    }
}
