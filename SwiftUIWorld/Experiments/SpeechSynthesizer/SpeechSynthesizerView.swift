//
//  SpeechSynthesizerView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 05/04/2023.
//

import SwiftUI
import AVFoundation

struct SpeechSynthesizerView: View {
    let synthesizer = AVSpeechSynthesizer()
    @State private var textToRead = "Salut ca va ?"
    
    var body: some View {
        VStack {
            TextEditor(text: $textToRead)
                .frame(height: 200)
                .padding()
            
            Button(action: {
                speak(textToRead)
            }, label: {
                Text("Lire le texte")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
        }
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_fr-FR_compact")

        
        synthesizer.speak(utterance)
        
    }
}

// com.apple.eloquence.fr-FR.Grandma - Grandma
// com.apple.eloquence.fr-FR.Flo - Flo
// com.apple.eloquence.fr-FR.Rocko - Rocko
// com.apple.eloquence.fr-FR.Grandpa - Grandpa
// com.apple.eloquence.fr-FR.Sandy - Sandy
// com.apple.eloquence.fr-FR.Eddy - Eddy

struct SpeechSynthesizerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechSynthesizerView()
    }
}
