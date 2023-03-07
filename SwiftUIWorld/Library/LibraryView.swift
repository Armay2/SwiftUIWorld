//
//  LibraryView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
               Form {
                   Section("Simple componantes") {
                       NavigationLink {
                           ButtonsView()
                       } label: {
                           Label("Button", systemImage: "button.programmable.square")
                       }
                       NavigationLink {
                           ButtonsView()
                       } label: {
                           Label("Color Picker", systemImage: "eyedropper.halffull")
                       }
                   }
                   
                   Section("Loading") {
                       NavigationLink {
                           RedactedView()
                       } label: {
                           Label("Redacted", systemImage: "text.justify.leading")
                       }
                   }
                   
                   Section("View Modifier") {
                       NavigationLink {
//                           RedactedView()
                       } label: {
                           Label("Mask", systemImage: "theatermask.and.paintbrush.fill")
                       }
                   }
               }
           }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
