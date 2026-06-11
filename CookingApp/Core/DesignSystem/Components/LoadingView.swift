//
//  LoadingView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 08/06/26.
//


import SwiftUI

struct LoadingView: View {
    var text: String // Bisa custom kata-katanya
    @State private var navigateToEdit = false
    var onSave: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
           
            
            // 2. Kotak Loading di tengah layar
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5) // Memperbesar ukuran spinner
                    .tint(.brandPrimary)     // Warna spinner
                
                Text(text)
                    .font(.body)
                    .foregroundStyle(Color.brandPrimary!)
                    .multilineTextAlignment(.center)
                
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            
            .cornerRadius(16)
        }
        .background {
            VStack {
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: -125, width: 600, height: 600)
                
                Spacer()
                
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: 125, width: 600, height: 600)
            }
            .ignoresSafeArea()
        }
//        Sembunyikan tombol back saat loading
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                navigateToEdit = true
            }
        }
        .navigationDestination(isPresented: $navigateToEdit) {
            EditDetailRecipeView(onSave: onSave)
                .navigationBarBackButtonHidden(true) // Sembunyikan back agar tidak kembali ke loading
        }
    }
}

#Preview {
    LoadingView(text: "Menganalisis Resep")
}
