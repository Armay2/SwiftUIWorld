//
//  CameraView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 10/04/2023.
//

import SwiftUI
import UIKit

struct CameraView: View {
    
    var body: some View {
        HostedCamera()
            .ignoresSafeArea()
    }
}




struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
