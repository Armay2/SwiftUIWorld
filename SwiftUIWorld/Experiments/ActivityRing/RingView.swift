//
//  RingView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 10/04/2023.
//

import SwiftUI

struct RingPath: Shape {
    var percent: Double
    
    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: ((percent / 100 * 360) + -90))
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = rect.width / 2
        
        return Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false)
        }
    }
}

struct RingView: View {
    var percent: Double
    var ringColor: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                RingPath(percent: 100)
                    .stroke(style: StrokeStyle(lineWidth: 20))
                    .fill(ringColor.opacity(0.2))
                RingPath(percent: percent)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .fill(ringColor)
            }.padding()
        }
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        RingView(percent: 12, ringColor: .blue)
    }
}
