//
//  ExperimentsView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

struct Experiment: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let destination: () -> AnyView
}

extension Experiment {
    static let all: [Experiment] = [
        Experiment(title: "ReflectiveUI",
                   systemImage: "camera.circle",
                   destination: { AnyView(ReflectiveUIView()) }),
        Experiment(title: "Speech Synthesizer",
                   systemImage: "speaker.wave.2.bubble.left.fill",
                   destination: { AnyView(SpeechSynthesizerView()) }),
        Experiment(title: "Activity Ring",
                   systemImage: "figure.run.circle",
                   destination: { AnyView(ActivityRingView()) }),
        Experiment(title: "Object Reflection View",
                   systemImage: "oval.portrait.inset.filled",
                   destination: { AnyView(ObjectReflectionView()) }),
        Experiment(title: "Fidelity View",
                   systemImage: "checkmark.seal.fill",
                   destination: { AnyView(FidelityView()) }),
        Experiment(title: "PushTo View",
                   systemImage: "arrow.down.left.and.arrow.up.right.square.fill",
                   destination: { AnyView(PushToView()) }),
        Experiment(title: "ManualTransitionFullScreen",
                   systemImage: "photo.artframe",
                   destination: {
                       if #available(iOS 18.0, *) {
                           AnyView(ManualTransitionFullScreen())
                       } else {
                           AnyView(Text("Only iOS 18+"))
                       }
                   }),
        Experiment(title: "ShareLocation View",
                   systemImage: "square.and.arrow.up.circle",
                   destination: { AnyView(ShareLocationView()) }),
        Experiment(title: "Lotties View",
                   systemImage: "heart.fill",
                   destination: { AnyView(LottiesView()) }),
        Experiment(title: "Confirm Button",
                   systemImage: "stop.circle",
                   destination: {
                       AnyView(ConfirmButton(action: { print("Confirmed!") }))
                   }),
        Experiment(title: "Flow Layout",
                   systemImage: "rectangle.3.group",
                   destination: { AnyView(DemoFlow()) }),
        Experiment(title: "Liquid Glass",
                   systemImage: "drop.fill",
                   destination: { AnyView(LiquidGlass()) }),
        Experiment(title: "Range Slider",
                   systemImage: "slider.horizontal.below.square.and.square.filled",
                   destination: { AnyView(RangeSliderPlayground()) }),
    ]
}

struct ExperimentsView: View {
    var body: some View {
        NavigationStack {
            List(Experiment.all) { experiment in
                NavigationLink {
                    experiment.destination()
                } label: {
                    Label(experiment.title, systemImage: experiment.systemImage)
                }
            }
            .navigationTitle("Experiments")
        }
    }
}

#Preview {
    ExperimentsView()
}
