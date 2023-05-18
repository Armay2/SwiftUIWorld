//
//  BottumView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 20/04/2023.
//

import SwiftUI

struct BottumView: View {
    @State private var isPresented = false
    
    var body: some View {
        TabView {
            VStack {
                Button("Show Bottom Sheet") {
                    isPresented.toggle()
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .fullScreenCover(isPresented: $isPresented) {
                VStack {
                    Spacer()
                    bottomSheetContent
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
    
    private var bottomSheetContent: some View {
        VStack {
            HStack {
                Text("Bottom Sheet")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .padding()
                })
            }
            .padding()
            .background(Color(.systemGray5))
            
            Spacer()
        }
        .frame(height: 300)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct BottumView_Previews: PreviewProvider {
    static var previews: some View {
        BottumView()
    }
}
