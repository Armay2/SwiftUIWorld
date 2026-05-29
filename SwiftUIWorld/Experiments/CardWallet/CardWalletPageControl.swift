//
//  CardWalletPageControl.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 22/05/2026.
//

import SwiftUI
import UIKit

struct CardWalletPageControl: UIViewRepresentable {
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
