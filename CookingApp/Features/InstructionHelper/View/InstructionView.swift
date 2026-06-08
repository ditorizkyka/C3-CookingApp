//
//  InstructorIntroView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct InstructionView: View {
    @State private var showIntro: Bool = false
    @State private var showInfoSheet: Bool = false
    @State private var showStepSheet: Bool = false
    
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
                        // Step Container
                        StepInstructionView(
                            currentStep: 2,
                            totalSteps: 12,
                            instruction: "Siapkan ayam yang telah digiling dengan chopper",
                            onRepeat: {
                                print("Tombol ulangi ditekan")
                            },
                            onStep: {
                                showStepSheet = true
                            }
                        )
                        
                        // Mic and Guide
                        MicAndGuideView(
                            guides: guides,
                            onHide: {
                                print("Sembunyikan")
                            }
                        )
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Navigation Controls (Bottom)
                    NavigationControlsView(
                        currentPage: 0,
                        totalPages: 5,
                        onPrevious: { print("Previous Step") },
                        onNext: { print("Next Step") }
                    )
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    VStack {
                        RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: -125)
                        
                        Spacer()
                        
                        RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: 125)
                    }
                    .ignoresSafeArea()
                }
                
                if showIntro {
                    Color.labelDark.opacity(0.25)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    IntroCard() {
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
                    Button {
                        print("Tutup ditekan")
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Speaker ditekan")
                    } label: {
                        Image(systemName: "speaker.slash")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInfoSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            InfoSheet()
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.surfaceElevated!)
            
        }
        
    }
}

#Preview {
    InstructionView()
}
