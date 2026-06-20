//
//  InstructionHelperView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI
import AVFoundation

struct InstructionHelperView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var viewModel: InstructionHelperViewModel
    
    init(recipe: Recipe, onGoToHome: (() -> Void)? = nil) {
        // Initialize the ViewModel inside the View
        _viewModel = StateObject(wrappedValue: InstructionHelperViewModel(recipe: recipe, onGoToHome: onGoToHome))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 16) {
                if viewModel.currentStepIndex >= 0 && viewModel.currentStepIndex < viewModel.allGranularSteps.count {
                    let instruction = viewModel.allGranularSteps[viewModel.currentStepIndex]
                    StepInstructionView(
                        currentStep: instruction.sequenceNumber,
                        totalSteps: viewModel.allGranularSteps.count,
                        instruction: instruction.text,
                        onRepeat: {
                            viewModel.repeatStep(speechManager: speechManager)
                        },
                        onStep: {
                            viewModel.showStepSheet = true
                        }
                    )
                    .padding(.horizontal, 32)
                }
                
                PulsingMicView(
                    audioLevel: speechManager.audioLevel,
                    isListening: speechManager.isListening,
                    isSpeaking: speechManager.isSpeaking
                )

                // Status label — bisa dibaca sekilas dari jauh saat masak
                phaseStatusLabel

                VoiceCommandGuideCard(guides: viewModel.guides)
            }
            .padding()
            
            Spacer()
            
            NavigationControlsView(
                currentPage: viewModel.currentStepIndex,
                totalPages: viewModel.allGranularSteps.count,
                onPrevious: {
                    viewModel.previousStep(speechManager: speechManager)
                },
                onNext: {
                    viewModel.nextStep(speechManager: speechManager)
                },
                onRepeat: {
                    viewModel.repeatStep(speechManager: speechManager)
                },
                onComplete: {
                    viewModel.completeFlow(speechManager: speechManager)
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            VStack {
                RadialGradientCircle(color: Color.ovalGreen.opacity(0.75), offset: -300, width: 600, height: 600)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
        .overlay {
            ListeningEdgeGlow(
                isListening: speechManager.isListening,
                isSpeaking: speechManager.isSpeaking
            )
        }
        .overlay {
            if viewModel.showIntro {
                ZStack {
                    Color.labelDark.opacity(0.25)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    IntroCard(
                        onDismiss: { viewModel.dismissIntro(speechManager: speechManager) },
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
        .navigationDestination(isPresented: $viewModel.navigateToComplete) {
            InstructionHelperCompleteView(recipe: viewModel.recipe, onGoToHome: viewModel.onGoToHome)
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
                    speechManager.isMuted.toggle()
                } label: {
                    Image(systemName: speechManager.isMuted ? "speaker.slash" : "speaker.wave.2")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showInfoSheet) {
            InfoSheet()
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.surfaceElevated)
        }
        .sheet(isPresented: $viewModel.showStepSheet) {
            if viewModel.currentStepIndex >= 0 && viewModel.currentStepIndex < viewModel.allGranularSteps.count {
                StepSheet(instructions: viewModel.recipe.instructions, activeGranularText: viewModel.allGranularSteps[viewModel.currentStepIndex].text) { selectedText in
                    viewModel.jumpToStep(withText: selectedText, speechManager: speechManager)
                }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.surfaceElevated)
            }
        }
        .onDisappear {
            viewModel.cleanUp(speechManager: speechManager)
        }
        .onChange(of: speechManager.recognizedText) { _, newValue in
            viewModel.handleRecognizedText(newValue, speechManager: speechManager)
        }
    }

    @ViewBuilder
    private var phaseStatusLabel: some View {
        let isActive = speechManager.isListening || speechManager.isSpeaking
        let label   = speechManager.isListening ? "Mendengarkan..." : "Menjawab..."
        let color   = speechManager.isListening
            ? Color.brandAccent
            : Color.brandSecondary

        ZStack {
            if isActive {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)

                    Text(label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(color)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .strokeBorder(color.opacity(0.4), lineWidth: 1)
                        )
                )
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: speechManager.isListening)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: speechManager.isSpeaking)
        .frame(height: 36)
    }
}

#Preview {
    //    let container = PreviewContainer.shared
    //    let ctx = container.mainContext
    //    let recipes = (try? ctx.fetch(FetchDescriptor<Recipe>())) ?? []
    //    return InstructionHelperView(recipe: recipes.first!)
    //        .modelContainer(container)
}
