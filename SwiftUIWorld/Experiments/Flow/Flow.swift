//
//  Flow.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 09/10/2025.
//

import SwiftUI

struct DemoFlow: View {
    private struct AmenityTag: View {
        let amenity: String

        var body: some View {
            Text(amenity)
                .font(.callout)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(Color.white)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.9))
                )
        }
    }
    
    var body: some View {
        VStack {
            Text("My Demo Flow")
                .font(.largeTitle)
                .bold()
            
            let amenities: [String] = [
                "SwiftUI", "KMM", "Mapbox", "Electra", "Live Activities",
                "Datadog", "Apollo", "Fastlane", "CI/CD", "GraphQL"
            ]
            
            FlowView {
                ForEach(amenities, id: \.self) { amenity in
                    AmenityTag(amenity: amenity)
                }
            }
            
            FlowView(spacing: 12) {
                ForEach(amenities, id: \.self) { amenity in
                    AmenityTag(amenity: amenity)
                }
            }
        }
    }
}

struct FlowView<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.spacing = 11
        self.content = content
    }

    init(spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        ScrollView {
            AnyLayout(FlowLayout(spacing: spacing)) {
                content()
            }
        }
    }
}

struct FlowLayout: Layout {
     var spacing: CGFloat = 8
 
     func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
         let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
         return layout(sizes: sizes,
                       spacing: spacing,
                       containerWidth: containerWidth).size
     }
     
     func placeSubviews(in bounds: CGRect,
                        proposal: ProposedViewSize,
                        subviews: Subviews,
                        cache: inout ()) {
         let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
         let offsets =
             layout(sizes: sizes,
                    spacing: spacing,
                    containerWidth: bounds.width).offsets
         for (offset, subview) in zip(offsets, subviews) {
             subview.place(at: .init(x: offset.x + bounds.minX,
                                     y: offset.y + bounds.minY),
                           proposal: .unspecified)
         }
     }
    
    func layout(sizes: [CGSize],
                 spacing: CGFloat = 8,
                 containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
         var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
         for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                 currentPosition.x = 0
                 currentPosition.y += lineHeight + spacing
                 lineHeight = 0
             }
             result.append(currentPosition)
             currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
             currentPosition.x += spacing
             lineHeight = max(lineHeight, size.height)
         }
         return (result,
             .init(width: maxX, height: currentPosition.y + lineHeight))
     }
 }


#Preview {
    DemoFlow()
}
