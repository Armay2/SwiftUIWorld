//
//  CameraView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 10/04/2023.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: View {
    let position: AVCaptureDevice.Position
    
    var body: some View {
        HostedCamera(cameraPosition: position)
    }
}




#Preview {
    CameraView(position: .back)
}
