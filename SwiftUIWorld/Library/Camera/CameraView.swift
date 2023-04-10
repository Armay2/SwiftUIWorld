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
    let postion: AVCaptureDevice.Position
    
    var body: some View {
        HostedCamera(cameraPostion: postion)
    }
}




struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(postion: .back)
    }
}
