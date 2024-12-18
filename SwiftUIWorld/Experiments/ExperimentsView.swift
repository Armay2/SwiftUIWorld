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
                       
                       NavigationLink {
                           FidelityView()
                       } label: {
                           Label("Fidelity View", systemImage: "checkmark.seal.fill")
                       }
                       
                       NavigationLink {
                           PushToView()
                       } label: {
                           Label("PushTo View", systemImage: "arrow.down.left.and.arrow.up.right.square.fill")
                       }
                       
                       NavigationLink {
                           if #available(iOS 18.0, *) {
                               TransitionFullScreen()
                           } else {
                               Text("ONly ios 18")
                           }
                       } label: {
                           Label("TransitionFullScreen", systemImage: "photo.artframe")
                       }

                       NavigationLink {
                           ShareLocationView()
                       } label: {
                           Label("ShareLocation View", systemImage: "square.and.arrow.up.circle")
                       }

                       NavigationLink {
                           LottiesView()
                       } label: {
                           Label("Lotties View", systemImage: "heart.fill")
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
