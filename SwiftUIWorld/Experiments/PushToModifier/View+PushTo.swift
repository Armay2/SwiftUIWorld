//
//  View+PushTo.swift
//  SwiftUIWorld
//
//  Created by Arnaud Nommay on 08/10/2024.
//

import Foundation

import SwiftUI

enum PushDirection {
    case left, right, top, bottom, centerHorizontal, centerVertical
}

extension View {
    func pushTo(_ direction: PushDirection) -> some View {
        switch direction {
        case .left:
            return HStack {
                self
                Spacer()
            }.eraseToAnyView()
        case .right:
            return HStack {
                Spacer()
                self
            }.eraseToAnyView()
        case .top:
            return VStack {
                self
                Spacer()
            }.eraseToAnyView()
        case .bottom:
            return VStack {
                Spacer()
                self
            }.eraseToAnyView()
        case .centerHorizontal:
            return HStack {
                Spacer()
                self
                Spacer()
            }.eraseToAnyView()
        case .centerVertical:
            return VStack {
                Spacer()
                self
                Spacer()
            }.eraseToAnyView()
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
