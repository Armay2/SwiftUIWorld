//
//  MapsView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 14/03/2023.
//

import SwiftUI
import MapKit

struct MapsView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.604, longitude: 1.44305), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))


    var body: some View {
        Map(coordinateRegion: $region).ignoresSafeArea()
    }
}

struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        MapsView()
    }
}
