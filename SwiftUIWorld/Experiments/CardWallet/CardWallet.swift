//
//  CardWallet.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 22/05/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A wallet-style horizontal carousel with a built-in dot indicator.
///
/// Swipe to move between items or tap a dot to jump. Neighbors scale down and
/// fade; the visible gap between cards stays constant during a swipe.
///
/// ```swift
/// @State private var selected = 0
///
/// WalletCarousel(items: myCards, selectedIndex: $selected) { card in
///     MyCardView(card: card)
/// }
/// ```
struct WalletCarousel<Item: Identifiable, CardContent: View>: View {
    let items: [Item]
    @Binding var selectedIndex: Int
    var cardSize: CGSize = CGSize(width: 331, height: 209)
    var cardGap: CGFloat = 24
    var showsIndicator: Bool = true
    @ViewBuilder var content: (Item) -> CardContent

    @State private var dragTranslation: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let scaleFalloff: CGFloat = 0.14
    private let minScale: CGFloat = 0.7
    private let dragRange: CGFloat = 200
    private let rubberBandFactor: CGFloat = 0.35
    private let snapAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.82)

    var body: some View {
        VStack(spacing: 16) {
            cardStack
            if showsIndicator {
                indicator
            }
        }
    }

    private var cardStack: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .frame(width: cardSize.width, height: cardSize.height)
                    .offset(x: offset(for: index) + dragTranslation)
                    .scaleEffect(scale(for: index))
                    .opacity(opacity(for: index))
                    .zIndex(-Double(abs(index - selectedIndex)))
                    .accessibilityHidden(index != selectedIndex)
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .contentShape(.rect)
        .gesture(dragGesture)
        .animation(activeAnimation, value: selectedIndex)
        .accessibilityElement(children: .contain)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment where selectedIndex < items.count - 1:
                selectedIndex += 1
            case .decrement where selectedIndex > 0:
                selectedIndex -= 1
            default:
                break
            }
        }
    }

    @ViewBuilder
    private var indicator: some View {
        #if canImport(UIKit)
        PageControl(numberOfPages: items.count, currentPage: $selectedIndex)
        #else
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                Circle()
                    .fill(i == selectedIndex ? Color.primary : Color.secondary.opacity(0.4))
                    .frame(width: 7, height: 7)
            }
        }
        #endif
    }

    private var activeAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : snapAnimation
    }

    private var step: CGFloat {
        cardSize.width * (1 + restScale(forDistance: 1)) / 2 + cardGap
    }

    private func restScale(forDistance d: Int) -> CGFloat {
        max(minScale, 1 - CGFloat(d) * scaleFalloff)
    }

    private func offset(for index: Int) -> CGFloat {
        let d = index - selectedIndex
        let base = CGFloat(d) * step
        let progress = dragProgress(toward: index)
        guard progress > 0 else { return base }
        // Push the incoming card outward as it scales up, so the gap stays constant.
        let scaleGrowth = (1 - restScale(forDistance: abs(d))) * progress
        return base + CGFloat(d.signum()) * cardSize.width * scaleGrowth / 2
    }

    private func scale(for index: Int) -> CGFloat {
        let effectiveDistance = abs(CGFloat(index - selectedIndex)) - dragProgress(toward: index)
        return max(minScale, 1 - max(effectiveDistance, 0) * scaleFalloff)
    }

    private func opacity(for index: Int) -> Double {
        let distance = abs(index - selectedIndex)
        return distance > 2 ? 0 : 1 - Double(distance) * 0.15
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragTranslation = rubberBanded(value.translation.width)
            }
            .onEnded { value in
                commitDrag(value.translation.width)
            }
    }

    private func rubberBanded(_ translation: CGFloat) -> CGFloat {
        let atFirst = selectedIndex == 0 && translation > 0
        let atLast = selectedIndex == items.count - 1 && translation < 0
        return (atFirst || atLast) ? translation * rubberBandFactor : translation
    }

    private func commitDrag(_ translation: CGFloat) {
        let threshold = step / 3
        var newIndex = selectedIndex
        if translation < -threshold, selectedIndex < items.count - 1 {
            newIndex += 1
        } else if translation > threshold, selectedIndex > 0 {
            newIndex -= 1
        }
        withAnimation(activeAnimation) {
            selectedIndex = newIndex
            dragTranslation = 0
        }
    }

    private func dragProgress(toward index: Int) -> CGFloat {
        guard dragTranslation != 0 else { return 0 }
        let d = index - selectedIndex
        let isIncoming = (dragTranslation < 0 && d == 1) || (dragTranslation > 0 && d == -1)
        guard isIncoming else { return 0 }
        return min(abs(dragTranslation) / dragRange, 1)
    }
}

#if canImport(UIKit)
private struct PageControl: UIViewRepresentable {
    let numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.backgroundStyle = .minimal
        control.pageIndicatorTintColor = UIColor.systemGray3
        control.currentPageIndicatorTintColor = UIColor.label
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage)
    }

    final class Coordinator: NSObject {
        @Binding var currentPage: Int

        init(currentPage: Binding<Int>) {
            self._currentPage = currentPage
        }

        @objc func valueChanged(_ sender: UIPageControl) {
            currentPage = sender.currentPage
        }
    }
}
#endif

#Preview {
    @Previewable @State var selected = 0
    WalletCarousel(items: Card.samples, selectedIndex: $selected) { card in
        CardView(card: card)
    }
    .padding()
}
