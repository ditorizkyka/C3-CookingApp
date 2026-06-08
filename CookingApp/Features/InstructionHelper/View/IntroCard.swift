//
//  InstructionHelperIntroCard.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct IntroCard: View {
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            // Title
            Text("Masak Praktis Lewat Suara")
                .font(Font.largeTitle)
                .multilineTextAlignment(.center)
            
            // Content
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 16) {
                    Image(systemName: "microphone.fill")
                        .font(Font.title)
                        .padding(12)
                    
                    Text("Kontrol lewat suara dengan berbicara")
                        .font(Font.body)
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "book.pages.fill")
                        .font(Font.title)
                        .padding(12)
                    
                    Text("Instruksi sederhana langkah demi langkah")
                        .font(Font.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Instruction
            Button {
                onDismiss!()
            } label: {
                HStack(spacing: 14) {
                    // Icon
                    Image(systemName: "person.wave.2.fill")
                        .font(Font.largeTitle)
                    
                    // Instruction
                    Text("Katakan “Mulai” untuk memulai")
                        .font(Font.title)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.large))
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 5,
                    x: 0,
                    y: 5
                )
            }
            .buttonStyle(.plain)
            
        }
        .padding(23)
        .glassEffect(in: RoundedRectangle(cornerRadius: Radius.large))
    }
}

#Preview {
    IntroCard()
}
