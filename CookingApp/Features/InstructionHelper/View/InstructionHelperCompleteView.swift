//
//  InstructionHelperCompleteView.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct InstructionHelperCompleteView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 64) {
            // Affirmation
            VStack(spacing: 8) {
                Text("Yeay")
                    .font(Font.largeTitle)
                
                Text("Masakanmu sudah siap!")
                    .font(Font.title)
                    .foregroundStyle(Color.labelLight!)
            }
            
            // Recipe
            VStack(spacing: 16) {
                // Title
                Text("Ayam Bakar Madu")
                    .font(Font.title)
                
                // Image
                Image("img_test")
                
                // Serving
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "person.fill")
                        
                        Text("6")
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "clock.fill")
                        
                        Text("10 min")
                    }
                }
                .font(Font.headline)
                .foregroundStyle(Color.brandAccent!)
            }
            
            // Button
            Button {
                print("Kembali ke Halaman Utama")
            } label: {
                Text("Kembali ke Halaman Utama")
            }
            .buttonStyle(.plain)
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(Color.brandAccent)
            .foregroundStyle(Color.labelLightest!)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        }
        .background(
            VStack {
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: -125)
                
                Spacer()
                
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: 125)
            }
            .ignoresSafeArea()
        )
    }
}

#Preview {
    InstructionHelperCompleteView()
}
