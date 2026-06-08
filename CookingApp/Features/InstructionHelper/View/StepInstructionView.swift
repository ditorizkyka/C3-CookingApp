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
    
    var body: some View {
        VStack(spacing: 16) {
            // Step
            Text("Langkah \(currentStep) dari \(totalSteps)")
                .font(Font.title)
                .foregroundStyle(Color.labelLight!)
            
            // Instruction
            Text(instruction)
                .font(Font.largeTitle)
                .multilineTextAlignment(.center)
            
            // Repeat
            Button {
                onRepeat()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("ulangi")
                }
                .font(Font.headline)
                .foregroundStyle(Color.labelLight!)
            }
            .buttonStyle(.plain)
        }
    }
}
