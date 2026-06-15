//
//  InstructionHelperView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

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
                
                PulsingMicView(audioLevel: speechManager.audioLevel, isListening: speechManager.isListening)
                
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
                RadialGradientCircle(color: Color.ovalGreen!.opacity(0.75), offset: -300, width: 600, height: 600)
                
                Spacer()
            }
            .ignoresSafeArea()
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
                .presentationBackground(Color.surfaceElevated!)
        }
        .sheet(isPresented: $viewModel.showStepSheet) {
            if viewModel.currentStepIndex >= 0 && viewModel.currentStepIndex < viewModel.allGranularSteps.count {
                StepSheet(instructions: viewModel.recipe.instructions, activeGranularText: viewModel.allGranularSteps[viewModel.currentStepIndex].text)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.surfaceElevated ?? .white)
            }
        }
        .onDisappear {
            viewModel.cleanUp(speechManager: speechManager)
        }
        .onChange(of: speechManager.recognizedText) { _, newValue in
            viewModel.handleRecognizedText(newValue, speechManager: speechManager)
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
