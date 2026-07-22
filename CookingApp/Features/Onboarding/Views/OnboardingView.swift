//
//  OnboardingView.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            // Icon
            VStack(alignment: .leading) {
                Image(systemName: "waveform.badge.microphone")
                    .font(Font.xXLargeTitle)
                    .foregroundStyle(Color.brandAccent)
                    .padding()
                    .background(Color.labelLight.opacity(0.05))
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
                OnboardingFeatureRow(
                    iconName: "microphone.fill",
                    title: "Kontrol Lewat Suara",
                    description: "Pindah instruksi cukup dengan berbicara."
                )
                
                OnboardingFeatureRow(
                    iconName: "voiceover",
                    title: "Bebas Repot",
                    description: "Tidak perlu khawatir mengotori HP saat tanganmu sedang sibuk."
                )
            }
            
            // Button
            ButtonApp(title: "Yuk! Coba Sekarang", iconButton: "frying.pan", type: .primary, action: {
                viewModel.completeOnboarding()
            })
            
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .background(
            RadialGradientCircle(color: Color.ovalGreen.opacity(0.75), offset: 400, width: 600, height: 600)
            .ignoresSafeArea()
        )
    }
}

#Preview {
    OnboardingView()
}
