//
//  FidelityView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 18/05/2023.
//

import SwiftUI

enum FidelitySteps: CaseIterable, Identifiable {
    case noob
    case bronze
    case iron
    case gold
    case diamond
    
    var id: Self {
        return self
    }
    
    var color: Color {
        switch self {
        case .noob:
            return .black
        case .bronze:
            return .brown
        case .iron:
            return .gray
        case .gold:
            return .yellow
        case .diamond:
            return .cyan
        }
    }
    
    var milestone: Double {
        switch self {
        case .noob:
            return 0
        case .bronze:
            return 500.0
        case .iron:
            return 1000.0
        case .gold:
            return 1500.0
        case .diamond:
            return 2000
        }
    }
    
}

struct FidelityGauge: View {
    @Binding var currentPoints: Double
    
    var currentStep: FidelitySteps {
        for step in FidelitySteps.allCases.reversed() {
            if currentPoints >= step.milestone {
                return step
            }
        }
        return .noob
    }
    
    var body: some View {
        VStack {
            ZStack {
                ProgressView(value: currentPoints, total: FidelitySteps.diamond.milestone)
                    .accentColor(currentStep.color)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                HStack {
                    ForEach(FidelitySteps.allCases) { step in
                        if step != .noob {
                            Spacer()
                        }
                        Circle()
                            .foregroundColor(currentPoints < step.milestone ? step.color : currentStep.color)
                            .frame(width: 20, height: 20)
                        if step != .diamond {
                            Spacer()
                        }
                    }
                }
            }
            Text(Int(currentPoints), format: .number)
        }
    }
    
}

struct FidelityView: View {
    @State private var points: Double = 300
    let gradient = Gradient(colors: [.brown, .gray, .yellow, .cyan])
    
    var body: some View {
        VStack {
            FidelityGauge(currentPoints: $points)
                .padding()
            Slider(value: $points, in: 0...FidelitySteps.diamond.milestone, step: 1)
                .padding()
        }
    }
}

struct FidelityView_Previews: PreviewProvider {
    static var previews: some View {
        FidelityView()
    }
}
