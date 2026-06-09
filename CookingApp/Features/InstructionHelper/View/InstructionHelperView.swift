//
//  InstructorIntroView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct InstructionHelperView: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Sinkronisasi Data
    var recipe: Recipe
    @State private var currentStepIndex: Int = 0
    
    @State private var showIntro: Bool = true
    @State private var showInfoSheet: Bool = false
    @State private var showStepSheet: Bool = false
    
    private var guides = [
        "Lanjut": "Langkah Berikutnya",
        "Ulangi": "Langkah Saat Ini",
        "Balik": "Langkah Sebelumnya"
    ]
    
    // MARK: - Explicit Initializer
    // Ditambahkan agar DetailRecipeView bisa mengirim data `recipe`, karena Swift menyembunyikan
    // auto-generated init jika ada private property (@State private var) dengan default value.
    init(recipe: Recipe = Recipe.dummyRecipes.first!) {
        self.recipe = recipe
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Image
                Rectangle()
                    .fill(
                        Color.gray.opacity(0.5)
                    )
                    .frame(height: 250)
                
                VStack(alignment: .center, spacing: 16) {
                    // MARK: - Konten Instruksi Dinamis
                    // Menampilkan instruksi yang sesuai dengan `currentStepIndex`
                    if currentStepIndex >= 0 && currentStepIndex < recipe.instructions.count {
                        let instruction = recipe.instructions[currentStepIndex]
                        StepInstructionView(
                            currentStep: instruction.sequenceNumber,
                            totalSteps: recipe.instructions.count,
                            instruction: instruction.text,
                            onRepeat: {
                                print("Tombol ulangi ditekan")
                            },
                            onStep: {
                                showStepSheet = true
                            }
                        )
                    }
                    
                    Spacer()
                    
                    PulsingMicView()
                    
                    VoiceCommandGuideCard(guides: guides)
                }
                .padding()
                
                Spacer()
                                // MARK: - Logika Tombol Next/Previous Dinamis
                                // Menambah atau mengurangi `currentStepIndex` agar instruksi berubah
                    NavigationControlsView(
                        currentPage: currentStepIndex,
                        totalPages: recipe.instructions.count,
                        onPrevious: {
                            if currentStepIndex > 0 {
                                withAnimation {
                                    currentStepIndex -= 1
                                }
                            }
                        },
                        onNext: {
                            if currentStepIndex < recipe.instructions.count - 1 {
                                withAnimation {
                                    currentStepIndex += 1
                                }
                            }
                        },
                        onRepeat: { print("Ulangi Step") }
                    )          }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
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
        .sheet(isPresented: $showInfoSheet) {
            InfoSheet()
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.surfaceElevated!)
            
        }
        .sheet(isPresented: $showStepSheet) {
            // MARK: - Kirim Data Penuh ke Sheet
            if currentStepIndex >= 0 && currentStepIndex < recipe.instructions.count {
                StepSheet(instructions: recipe.instructions, currentStep: recipe.instructions[currentStepIndex].sequenceNumber)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.surfaceElevated ?? .white)
            }
        }
    }
}

#Preview {
    InstructionHelperView()
}
