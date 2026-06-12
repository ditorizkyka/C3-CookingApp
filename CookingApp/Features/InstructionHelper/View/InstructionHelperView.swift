//
//  InstructorIntroView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct InstructionHelperView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var speechManager = SpeechManager()
    
    var recipe: Recipe
    @State private var currentStepIndex: Int = 0
    
    @State private var showIntro: Bool = true
    @State private var showInfoSheet: Bool = false
    @State private var showStepSheet: Bool = false
    @State private var navigateToComplete: Bool = false
    
    private var guides = [
        "Lanjut": "Langkah Berikutnya",
        "Ulangi": "Langkah Saat Ini",
        "Balik": "Langkah Sebelumnya"
    ]
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    private func dismissIntro() {
        withAnimation(.easeInOut(duration: 0.4)) {
            showIntro = false
        }
        
        speechManager.stopListening()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            speechManager.startListening()
            if !recipe.instructions.isEmpty {
                speechManager.speak(text: recipe.instructions[currentStepIndex].text)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 16) {
                    if currentStepIndex >= 0 && currentStepIndex < recipe.instructions.count {
                        let instruction = recipe.instructions[currentStepIndex]
                        StepInstructionView(
                            currentStep: instruction.sequenceNumber,
                            totalSteps: recipe.instructions.count,
                            instruction: instruction.text,
                            onRepeat: {
                                speechManager.stopSpeaking()
                                speechManager.speak(text: instruction.text)
                            },
                            onStep: {
                                showStepSheet = true
                            }
                        )
                        .padding(.horizontal, 32)
                    }
                    
                    PulsingMicView(audioLevel: speechManager.audioLevel, isListening: speechManager.isListening)
                    
                    VoiceCommandGuideCard(guides: guides)
                }
                .padding()
                
                Spacer()
                
                NavigationControlsView(
                    currentPage: currentStepIndex,
                    totalPages: recipe.instructions.count,
                    onPrevious: {
                        if currentStepIndex > 0 {
                            withAnimation {
                                currentStepIndex -= 1
                            }
                            speechManager.stopSpeaking()
                            speechManager.speak(text: recipe.instructions[currentStepIndex].text)
                        }
                    },
                    onNext: {
                        if currentStepIndex < recipe.instructions.count - 1 {
                            withAnimation {
                                currentStepIndex += 1
                            }
                            speechManager.stopSpeaking()
                            speechManager.speak(text: recipe.instructions[currentStepIndex].text)
                        }
                    },
                    onRepeat: {
                        speechManager.stopSpeaking()
                        speechManager.speak(text: recipe.instructions[currentStepIndex].text)
                    },
                    onComplete: {
                        speechManager.stopSpeaking()
                        navigateToComplete = true
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background {
                VStack {
                    RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: -300, width: 600, height: 600)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            }
            .overlay {
                if showIntro {
                    ZStack {
                        Color.labelDark.opacity(0.25)
                            .ignoresSafeArea()
                            .transition(.opacity)
                        
                        IntroCard(
                            onDismiss: { dismissIntro() },
                            audioLevel: speechManager.audioLevel,
                            isListening: speechManager.isListening
                        )
                        .onAppear {
                            speechManager.requestPermissions()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                speechManager.startListening()
                            }
                        }
                        .padding()
                        .transition(.opacity.combined(with: .scale(scale: 0.1)))
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToComplete) {
                InstructionHelperCompleteView(recipe: recipe)
            }
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
                    .presentationDetents([.fraction(0.6)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.surfaceElevated!)
                
            }
            .sheet(isPresented: $showStepSheet) {
                if currentStepIndex >= 0 && currentStepIndex < recipe.instructions.count {
                    StepSheet(instructions: recipe.instructions, currentStep: recipe.instructions[currentStepIndex].sequenceNumber)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Color.surfaceElevated ?? .white)
                }
            }
        }
        .onDisappear {
            speechManager.stopListening(permanent: true)
            speechManager.stopSpeaking()
        }
        .onChange(of: speechManager.recognizedText) { _, newValue in
            let text = newValue.lowercased()
            
            if showIntro && text.contains("mulai") {
                speechManager.recognizedText = ""
                dismissIntro()
                
            } else if text.contains("lanjut") {
                if currentStepIndex < recipe.instructions.count - 1 {
                    withAnimation {
                        currentStepIndex += 1
                    }
                    speechManager.speak(text: recipe.instructions[currentStepIndex].text)
                } else {
                    navigateToComplete = true
                }
                speechManager.recognizedText = "" 
            } else if text.contains("balik") {
                if currentStepIndex > 0 {
                    withAnimation {
                        currentStepIndex -= 1
                    }
                    speechManager.speak(text: recipe.instructions[currentStepIndex].text)
                }
                speechManager.recognizedText = ""
                
            } else if text.contains("ulangi") {
                speechManager.speak(text: recipe.instructions[currentStepIndex].text)
                speechManager.recognizedText = ""
            }
        }
        
    }
}

#Preview {
//    let container = PreviewContainer.shared
//    let ctx = container.mainContext
//    let recipes = (try? ctx.fetch(FetchDescriptor<Recipe>())) ?? []
//    return InstructionHelperView(recipe: recipes.first!)
//        .modelContainer(container)
}
