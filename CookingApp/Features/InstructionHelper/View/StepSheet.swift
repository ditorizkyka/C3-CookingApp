//
//  Step.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct StepSheet: View {
    var instructions: [Instruction] = Recipe.dummyRecipes.first?.instructions ?? []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Langkah-Langkah")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                ForEach(instructions, id: \.id) { instruction in
                    InstructionDetailCard(
                        stepNumber: instruction.sequenceNumber,
                        mainInstruction: instruction.text,
                        subInstructions: instruction.breakdownInstruction.map { $0.text }
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    StepSheet()
}
