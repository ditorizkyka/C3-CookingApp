//
//  InstructionHelperIntroCard.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct IntroCard: View {
    var onDismiss: (() -> Void)? = nil
    var audioLevel: Float = 0.0
    var isListening: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 9) {
            // Mic
            PulsingMicView(audioLevel: audioLevel, isListening: isListening)
            
            // Subtitle
            Text("Katakan \"Mulai\"")
                .font(Font.title)
                .multilineTextAlignment(.center)
            
            Text("atau")
                .font(Font.body)
                .foregroundStyle(Color.labelLight)
            
            Button {
                onDismiss!()
            } label: {
                Text("Tekan disini untuk memulai")
                    .font(Font.headline)
            }
            .buttonStyle(.plain)
            .padding()
            .foregroundStyle(Color.brandAccent)
            .frame(maxWidth: .infinity)
            .background(Color.surfaceBrand)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.large)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(Color.brandPrimary)
            )
            
            // Content
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(systemName: "microphone.fill")
                        .font(Font.title)
                        .padding(12)
                    
                    Text("Kontrol dengan berbicara")
                        .font(Font.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 0) {
                    Image(systemName: "book.pages.fill")
                        .font(Font.title)
                        .padding(12)
                    
                    Text("Instruksi sederhana")
                        .font(Font.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Color.labelLight)
            .frame(maxWidth: .infinity)
            
        }
        .padding(23)
        .glassEffect(in: RoundedRectangle(cornerRadius: Radius.large))
    }
}

#Preview {
    IntroCard()
}
