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
            Text("Tab Content 2")
                .tabItem {
                    Label("Navigation", systemImage: "map.fill")
                }
            ExperimentsView()
                .tabItem {
                    Label("Experiments", systemImage: "testtube.2")
                }
            Text("Tab Content 2")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
