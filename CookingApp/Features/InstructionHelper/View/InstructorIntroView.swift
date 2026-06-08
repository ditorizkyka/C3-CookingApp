//
//  InstructorIntroView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct InstructorIntroView: View {
    @State private var showIntro: Bool = false
    
    private var guides = [
        "Lanjut": "Langkah Berikutnya",
        "Ulangi": "Langkah Saat Ini",
        "Balik": "Langkah Sebelumnya"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Image
                    Rectangle()
                        .fill(
                            Color.gray.opacity(0.5)
                        )
                        .frame(height: 250)
                    
                    VStack(alignment: .center, spacing: 16) {
                        VStack(spacing: 16) {
                            // Step
                            Text("Langkah 2 dari 12")
                                .font(Font.title)
                                .foregroundStyle(Color.labelLight!)
                            
                            // Instruction
                            Text("Siapkan ayam yang telah digiling dengan chopper")
                                .font(Font.largeTitle)
                                .multilineTextAlignment(.center)
                            
                            // Repeat
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                
                                Text("ulangi")
                            }
                            .font(Font.headline)
                            .foregroundStyle(Color.labelLight!)
                        }
                        
                        // Microphone
                        HStack {
                            Image(systemName: "wave.3.left")
                                .font(Font.title)
                            Image(systemName: "microphone.fill")
                                .font(Font.largeTitle)
                            Image(systemName: "wave.3.right")
                                .font(Font.title)
                        }
                        .foregroundStyle(Color.brandPrimary!)
                        .fontWeight(.regular)
                        
                        // Guide
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Petunjuk Perintah Suara")
                            }
                            
                            ForEach(guides.sorted(by: >), id: \.key) { guide in
                                HStack {
                                    Text("• **‘\(guide.key)’** : ")
                                    Text(guide.value)
                                }
                                
                            }
                            
                            // Hide
                            Button {
                                print("Sembunyikan")
                            } label: {
                                Text("Sembunyikan")
                                    .underline()
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.brandPrimary!)
                        }
                        .font(Font.footnote)
                        .foregroundStyle(Color.labelLight!)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.medium)
                                .stroke(style: StrokeStyle(lineWidth: 1)
                                       )
                        )
                    }
                    .padding()
                    
                    Spacer()
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    VStack {
                        RadialGradiantCircle(color: Color.ovalGreen!.opacity(0.75), offset: -125)
                        
                        Spacer()
                        
                        RadialGradiantCircle(color: Color.ovalGreen!.opacity(0.75), offset: 125)
                    }
                    .ignoresSafeArea()
                }
                
                if showIntro {
                    Color.labelDark.opacity(0.25)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    InstructionHelperIntroCard {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showIntro = false
                        }
                    }
                    .padding()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "xmark")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "speaker.slash")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "info.circle")
                }
            }
            .padding(.vertical)
        }
        
    }
}

#Preview {
    InstructorIntroView()
}
