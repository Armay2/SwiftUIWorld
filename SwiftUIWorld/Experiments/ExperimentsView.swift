//
//  ExperimentsView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

/// One playground experiment. Each case carries its own title, icon, and destination
/// view, so the list stays fully type-safe — no `AnyView` erasure required. Adding a
/// case forces the compiler to flag every `switch` that needs updating.
enum Experiment: Identifiable {
    case reflectiveUI
    case speechSynthesizer
    case activityRing
    case objectReflection
    case fidelity
    case pushTo
    case manualTransitionFullScreen
    case shareLocation
    case lotties
    case confirmButton
    case flowLayout
    case liquidGlass
    case rangeSlider
    case cardWallet
    case slideToStop
    case toolBox

    var id: Self { self }

    var title: String {
        switch self {
        case .reflectiveUI:               "ReflectiveUI"
        case .speechSynthesizer:          "Speech Synthesizer"
        case .activityRing:               "Activity Ring"
        case .objectReflection:           "Object Reflection View"
        case .fidelity:                   "Fidelity View"
        case .pushTo:                     "PushTo View"
        case .manualTransitionFullScreen: "ManualTransitionFullScreen"
        case .shareLocation:              "ShareLocation View"
        case .lotties:                    "Lotties View"
        case .confirmButton:              "Confirm Button"
        case .flowLayout:                 "Flow Layout"
        case .liquidGlass:                "Liquid Glass"
        case .rangeSlider:                "Range Slider"
        case .cardWallet:                 "Card Wallet"
        case .slideToStop:                "Slide to Stop"
        case .toolBox:                    "ToolBox"
        }
    }

    var systemImage: String {
        switch self {
        case .reflectiveUI:               "camera.circle"
        case .speechSynthesizer:          "speaker.wave.2.bubble.left.fill"
        case .activityRing:               "figure.run.circle"
        case .objectReflection:           "oval.portrait.inset.filled"
        case .fidelity:                   "checkmark.seal.fill"
        case .pushTo:                     "arrow.down.left.and.arrow.up.right.square.fill"
        case .manualTransitionFullScreen: "photo.artframe"
        case .shareLocation:              "square.and.arrow.up.circle"
        case .lotties:                    "heart.fill"
        case .confirmButton:              "stop.circle"
        case .flowLayout:                 "rectangle.3.group"
        case .liquidGlass:                "drop.fill"
        case .rangeSlider:                "slider.horizontal.below.square.and.square.filled"
        case .cardWallet:                 "creditcard.fill"
        case .slideToStop:                "bolt.slash.fill"
        case .toolBox:                    "bolt.car.fill"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .reflectiveUI:               ReflectiveUIView()
        case .speechSynthesizer:          SpeechSynthesizerView()
        case .activityRing:               ActivityRingView()
        case .objectReflection:           ObjectReflectionView()
        case .fidelity:                   FidelityView()
        case .pushTo:                     PushToView()
        case .manualTransitionFullScreen:
            if #available(iOS 18.0, *) {
                ManualTransitionFullScreen()
            } else {
                Text("Only iOS 18+")
            }
        case .shareLocation:              ShareLocationView()
        case .lotties:                    LottiesView()
        case .confirmButton:              ConfirmButton(action: { print("Confirmed!") })
        case .flowLayout:                 DemoFlow()
        case .liquidGlass:                LiquidGlass()
        case .rangeSlider:                RangeSliderPlayground()
        case .cardWallet:                 CardWalletPlayground()
        case .slideToStop:                SlideToStopPlayground()
        case .toolBox:
            if #available(iOS 26.0, *) {
                ToolBox()
            } else {
                Text("Only iOS 26+")
            }
        }
    }
}

/// A titled group of related experiments, rendered as one `Section` in the list.
struct ExperimentSection: Identifiable {
    let title: String
    let experiments: [Experiment]

    var id: String { title }
}

extension ExperimentSection {
    static let all: [ExperimentSection] = [
        ExperimentSection(
            title: "Controls & Components",
            experiments: [.confirmButton, .activityRing, .rangeSlider, .slideToStop, .cardWallet, .fidelity]
        ),
        ExperimentSection(
            title: "Layout & Navigation",
            experiments: [.flowLayout, .pushTo, .manualTransitionFullScreen]
        ),
        ExperimentSection(
            title: "Camera & Reflection",
            experiments: [.reflectiveUI, .objectReflection]
        ),
        ExperimentSection(
            title: "System & Media",
            experiments: [.speechSynthesizer, .shareLocation, .lotties]
        ),
        ExperimentSection(
            title: "Liquid Glass (iOS 26)",
            experiments: [.liquidGlass, .toolBox]
        ),
    ]
}

struct ExperimentsView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(ExperimentSection.all) { section in
                    Section(section.title) {
                        ForEach(section.experiments) { experiment in
                            NavigationLink {
                                experiment.destination
                            } label: {
                                Label(experiment.title, systemImage: experiment.systemImage)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Experiments")
        }
    }
}

#Preview {
    ExperimentsView()
}
