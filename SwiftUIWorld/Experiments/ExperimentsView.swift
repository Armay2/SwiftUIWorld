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
