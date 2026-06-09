//
//  Onboarding.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            // Icon
            VStack(alignment: .leading) {
                Image(systemName: "waveform.badge.microphone")
                    .font(Font.xXLargeTitle)
                    .foregroundStyle(Color.brandAccent!)
                    .padding()
                    .background(Color.labelLight!.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Masak Praktis Lewat Suara")
                    .font(Font.largeTitle)
                
                Text("Ikuti panduan resep lewat suara. Kamu bisa fokus memasak tanpa perlu menyentuh HP dengan tangan kotor.")
                    .font(Font.body)
                    .foregroundStyle(.secondary)
            }
            
            // Fitur
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: "microphone.fill")
                        .font(Font.title)
                        .foregroundStyle(Color.brandAccent!)
                        .padding()
                        .background(Color.labelLight!.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                    
                    // Detail
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text("Kontrol Lewat Suara")
                            .font(Font.headline)
                        
                        // Description
                        Text("Pindah instruksi cukup dengan berbicara.")
                            .font(Font.body)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: "voiceover")
                        .font(Font.title)
                        .foregroundStyle(Color.brandAccent!)
                        .padding()
                        .background(Color.labelLight!.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                    
                    // Detail
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text("Bebas Repot")
                            .font(Font.headline)
                        
                        // Description
                        Text("Tidak perlu khawatir mengotori HP saat tanganmu sedang sibuk.")
                            .font(Font.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Button
            ButtonApp(title: "Yuk! Coba Sekarang", iconButton: "frying.pan", type: .primary, action: {
                withAnimation {
                    hasSeenOnboarding = true
                }
            })
            
        }
        .padding(32)
        .background(
            RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: 400)
            .ignoresSafeArea()
        )
    }
}

#Preview {
    OnboardingView()
}
