//
//  RedactedView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 06/03/2023.
//

import SwiftUI

struct RedactedView: View {
    var body: some View {
        Text("Hello, World!").redacted(reason: .placeholder)
        
        
//            .redacted(reason: article == nil ? .placeholder : [])

    }
}

#Preview {
    RedactedView()
}
