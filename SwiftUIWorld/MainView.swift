//
//  MainView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView() {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            NavigationStack {
                Text("Navigation")
                    .navigationTitle("Navigation")
            }
            .tabItem {
                Label("Navigation", systemImage: "map.fill")
            }
            ExperimentsView()
                .tabItem {
                    Label("Experiments", systemImage: "testtube.2")
                }
            NavigationStack {
                Text("Settings")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    MainView()
}
