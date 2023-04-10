//
//  ActivityRingVeiw.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 10/04/2023.
//

import SwiftUI

struct ActivityRingView: View {
    @State private var animate = false
    @State private var cyanRing = 40.0
    @State private var yellowRing = 60.0
    @State private var redRing = 70.0

    var body: some View {
        VStack {
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 250, height: 250)
                RingView(percent: animate ? 100 : redRing, ringColor: .red)
                    .frame(width: 200, height: 200)
                RingView(percent: animate ? 100 : yellowRing, ringColor: .yellow)
                    .frame(width: 150, height: 150)
                RingView(percent: animate ? 100 : cyanRing, ringColor: .cyan)
                    .frame(width: 100, height: 100)
            }
            .onTapGesture {
                withAnimation(Animation.spring()) {
                    animate.toggle()
                }
            }
            
            Spacer()
            
            VStack {
                Slider(value: $redRing, in: 0...100)
                    .tint(.red)
                Slider(value: $yellowRing, in: 0...100)
                    .tint(.yellow)
                Slider(value: $cyanRing, in: 0...100)
                    .tint(.cyan)
            }.padding()
            
            Spacer()

        }
    }
}

struct ActivityRingVeiw_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRingView()
    }
}
