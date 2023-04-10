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
        CameraPreviewView()
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
        camera
            .mask(navigationView)
//        navigationView
    }
    
    var camera: some View {
        CameraPreviewView()
            .blur(radius: 8)
    }
    
    var navigationView: some View  {
        VStack(alignment: .leading) {
            Text("Title").font(.title)
            Spacer()
            ForEach((1...10).reversed(), id: \.self) {
                Text("This is \($0)")
            }
        }
    }
}

struct ReflectiveUIView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectiveUIView()
    }
}
