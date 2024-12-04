//
//  ContentView.swift
//  SwiftUIWorld
//
//  Created by Arnaud Nommay on 30/10/2024.
//
import SwiftUI

struct TransitionFullScreen: View {
    @State var selectedImageIndex: Int = 0
    @State var showCarousel: Bool = false
    
    let imageSources: [ImageResource] = [.landscapeOne, .landscapeTwo, .landscapeThree]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(imageSources.indices, id: \ .self) { index in
                        let source = imageSources[index]
                        Button {
                            withAnimation {
                                selectedImageIndex = index
                                showCarousel.toggle()
                            }
                        } label: {
                            Image(source)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .padding([.horizontal])
                .padding(.top, 100)
                
            }
            Spacer()
        }
        .overlay {
            if showCarousel {
                FullScreenImageView(
                    imageSources: imageSources,
                    selectedImageIndex: $selectedImageIndex,
                    showCarousel: $showCarousel
                )
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut, value: showCarousel)
            }
        }
    }
}

struct FullScreenImageView: View {
    let imageSources: [ImageResource]
    @Binding var selectedImageIndex: Int
    @Binding var showCarousel: Bool
        
    var body: some View {
        VStack {
            TabView(selection: $selectedImageIndex) {
                ForEach(imageSources.indices, id: \ .self) { index in
                    let source = imageSources[index]
                    Image(source)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .background(.background.opacity(0.9))
        .onTapGesture {
            withAnimation {
                showCarousel.toggle()
            }
        }
    }
}

#Preview("TransitionFullScreenTwo") {
    TransitionFullScreen()
}
