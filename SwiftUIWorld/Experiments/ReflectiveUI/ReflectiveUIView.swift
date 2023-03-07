//
//  ReflectiveUIView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI
import AVFoundation

struct ReflectiveUIView: View {
    let text = "MY Blured"
    
    var body: some View {
        CameraPreviewView()
        .blur(radius: 8) // Ajout du flou à la vue CameraPreview
        .mask(
            Text("My blured text").font(.largeTitle).bold()
        )
        
        
        
//        VStack {
//            Button("Press me!") {
//                // Action when button is pressed
//            }
//            .padding()
//            .background(
//                    CameraPreviewView()
////                        .frame(height: 200)
//                    //.blur(radius: 8) // Ajout du flou à la vue CameraPreview
//            )
//            .cornerRadius(8)
//            .shadow(radius: 5)
//        }
        
        //        List {
        //            Text("My text")
        ////            camera.mask(navigationView)
        //        }
    }
}

struct ReflectiveUIView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectiveUIView()
    }
}
