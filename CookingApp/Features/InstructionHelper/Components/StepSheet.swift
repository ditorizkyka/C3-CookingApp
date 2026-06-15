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
    var activeGranularText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        ForEach(instructions.sorted(by: { $0.sequenceNumber < $1.sequenceNumber }), id: \.id) { instruction in
                            let sortedSubInstructions = instruction.breakdownInstruction.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
                            let subTexts = sortedSubInstructions.map { $0.text }
                            let isCurrent = subTexts.contains(activeGranularText) || instruction.text == activeGranularText
                            
                            InstructionDetailCard(
                                stepNumber: instruction.sequenceNumber,
                                mainInstruction: instruction.text,
                                subInstructions: subTexts,
                                isCurrent: isCurrent,
                                activeSubInstruction: activeGranularText
                            )
                            .id(instruction.id)
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
                .onAppear {
                    if let currentId = instructions.first(where: {
                        $0.breakdownInstruction.map { $0.text }.contains(activeGranularText) || $0.text == activeGranularText
                    })?.id {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(currentId, anchor: .top)
                            }
                        }
                    }
                }
                .onChange(of: activeGranularText) { _, newText in
                    if let currentId = instructions.first(where: {
                        $0.breakdownInstruction.map { $0.text }.contains(newText) || $0.text == newText
                    })?.id {
                        withAnimation {
                            proxy.scrollTo(currentId, anchor: .top)
                        }
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
