//
//  StepInstructionView.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct StepInstructionView: View {
    var currentStep: Int
    var totalSteps: Int
    var instruction: String
    var onRepeat: () -> Void
    var onStep: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Step
            Button {
                onStep()
            } label: {
                HStack {
                    Text("Langkah \(currentStep) dari \(totalSteps)")
                        .font(Font.title)
                        .foregroundStyle(Color.labelLight)
                    
                    Image(systemName: "chevron.down.circle.fill")
                        .foregroundStyle(Color.labelLight)
                }
            }
            
            
            // Instruction
            Text(instruction)
                .font(Font.largeTitle)
                .multilineTextAlignment(.center)
                .lineLimit(4)
        }
    }
}
