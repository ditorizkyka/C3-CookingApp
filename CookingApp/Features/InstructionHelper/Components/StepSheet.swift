//
//  Step.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct StepSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var instructions: [Instruction] = []
    var currentStep: Int = 1
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    ForEach(instructions, id: \.id) { instruction in
                        InstructionDetailCard(
                            stepNumber: instruction.sequenceNumber,
                            mainInstruction: instruction.text,
                            subInstructions: instruction.breakdownInstruction.map { $0.text },
                            isCurrent: instruction.sequenceNumber == currentStep
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
//    let container = PreviewContainer.shared
//    let ctx = container.mainContext
//    let recipes = (try? ctx.fetch(FetchDescriptor<Recipe>())) ?? []
//    return StepSheet(instructions: recipes.first?.instructions ?? [])
//        .modelContainer(container)
}
