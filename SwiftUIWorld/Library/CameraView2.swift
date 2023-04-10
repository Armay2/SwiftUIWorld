//
//  CameraView2.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 10/04/2023.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let captureSession = AVCaptureSession()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        let captureButton = UIButton()
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .blue
        captureButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        view.addSubview(captureButton)
        self.previewView = view
        self.captureButton = captureButton
        return view
    }
}
struct CameraView2: View {
    @State private var image: UIImage?
    @State private var previewView: UIView?
    @State private var captureButton: UIButton?
    
    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            previewView
            captureButton
        }
    }
}

struct CameraView2_Previews: PreviewProvider {
    static var previews: some View {
        CameraView2()
    }
}
