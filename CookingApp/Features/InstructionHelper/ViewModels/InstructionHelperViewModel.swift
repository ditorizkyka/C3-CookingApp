//
//  InstructionHelperViewModel.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI
import Combine

class InstructionHelperViewModel: ObservableObject {
    @Published var currentStepIndex: Int = 0
    @Published var showIntro: Bool = true
    @Published var showInfoSheet: Bool = false
    @Published var showStepSheet: Bool = false
    @Published var navigateToComplete: Bool = false
    
    let recipe: Recipe
    let allGranularSteps: [Instruction]
    var onGoToHome: (() -> Void)?
    
    let guides = [
        "Kembali": "Langkah Sebelumnya",
        "Ulangi": "Langkah Saat Ini",
        "Lanjut": "Langkah Berikutnya",
    ]
    
    init(recipe: Recipe, onGoToHome: (() -> Void)? = nil) {
        self.recipe = recipe
        self.onGoToHome = onGoToHome
        
        var allSteps: [Instruction] = []
        let sortedMain = recipe.instructions.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
        
        for mainStep in sortedMain {
            let sortedSub = mainStep.breakdownInstruction.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
            if sortedSub.isEmpty {
                allSteps.append(mainStep)
            } else {
                allSteps.append(contentsOf: sortedSub)
            }
        }
        
        var seq = 1
        self.allGranularSteps = allSteps.map { orig in
            let newInst = Instruction(sequenceNumber: seq, text: orig.text, photoUrl: orig.photoUrl)
            seq += 1
            return newInst
        }
    }
    
    func dismissIntro(speechManager: SpeechManager) {
        withAnimation(.easeInOut(duration: 0.4)) {
            showIntro = false
        }
        
        speechManager.stopListening()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            speechManager.startListening()
            if !self.allGranularSteps.isEmpty {
                speechManager.speak(text: self.allGranularSteps[self.currentStepIndex].text)
            }
        }
    }
    
    func nextStep(speechManager: SpeechManager) {
        if currentStepIndex < allGranularSteps.count - 1 {
            withAnimation {
                currentStepIndex += 1
            }
            speechManager.stopSpeaking()
            speechManager.speak(text: allGranularSteps[currentStepIndex].text)
        } else {
            speechManager.stopListening(permanent: true)
            speechManager.stopSpeaking()
            navigateToComplete = true
        }
    }
    
    func previousStep(speechManager: SpeechManager) {
        if currentStepIndex > 0 {
            withAnimation {
                currentStepIndex -= 1
            }
            speechManager.stopSpeaking()
            speechManager.speak(text: allGranularSteps[currentStepIndex].text)
        }
    }
    
    func repeatStep(speechManager: SpeechManager) {
        speechManager.stopSpeaking()
        speechManager.speak(text: allGranularSteps[currentStepIndex].text)
    }
    
    func completeFlow(speechManager: SpeechManager) {
        speechManager.stopListening(permanent: true)
        speechManager.stopSpeaking()
        navigateToComplete = true
    }
    

    func jumpToStep(withText targetText: String, speechManager: SpeechManager) {
        if let idx = allGranularSteps.firstIndex(where: { $0.text == targetText }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStepIndex = idx
            }
            speechManager.stopSpeaking()
            speechManager.speak(text: allGranularSteps[idx].text)
        }
    }
    
    func handleRecognizedText(_ newValue: String, speechManager: SpeechManager) {
        let text = newValue.lowercased()
        
        if showIntro && text.contains("mulai") {
            speechManager.recognizedText = ""
            dismissIntro(speechManager: speechManager)
            
        } else if text.contains("lanjut") || text.contains("next") {
            speechManager.recognizedText = ""
            nextStep(speechManager: speechManager)
            
        } else if text.contains("kembali") || text.contains("back") {
            speechManager.recognizedText = ""
            previousStep(speechManager: speechManager)
            
        } else if text.contains("ulangi") || text.contains("repeat") {
            speechManager.recognizedText = ""
            repeatStep(speechManager: speechManager)
        }
    }
    
    func cleanUp(speechManager: SpeechManager) {
        speechManager.stopListening(permanent: true)
        speechManager.stopSpeaking()
    }
}
