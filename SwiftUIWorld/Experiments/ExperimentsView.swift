//
//  ExperimentsView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

struct ExperimentsView: View {
    var body: some View {
        NavigationView {
               Form {
                   Section("Basics") {
                       NavigationLink {
                           ReflectiveUIView()
                       } label: {
                           Label("ReflectiveUI", systemImage: "camera.circle")
                       }
                       
                       NavigationLink {
                           SpeechSynthesizerView()
                       } label: {
                           Label("Speech Synthesizer", systemImage: "speaker.wave.2.bubble.left.fill")
                       }
                       
                       NavigationLink {
                           ActivityRingView()
                       } label: {
                           Label("Activity Ring", systemImage: "figure.run.circle")
                       }
                       
                       NavigationLink {
                           ObjectReflectionView()
                       } label: {
                           Label("Object Reflection View", systemImage: "oval.portrait.inset.filled")
                       }
                   }
               }.navigationTitle("Experiments")
           }
    }
}

struct ExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentsView()
    }
}
