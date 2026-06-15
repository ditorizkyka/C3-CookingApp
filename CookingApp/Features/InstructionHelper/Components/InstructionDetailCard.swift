//
//  DisclosureInstructionDetailCard.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct InstructionDetailCard: View {
    let stepNumber: Int
    let mainInstruction: String
    let subInstructions: [String]
    var isCurrent: Bool = false
    var activeSubInstruction: String = ""
    
    @State private var isExpanded: Bool
    
    init(stepNumber: Int, mainInstruction: String, subInstructions: [String], isCurrent: Bool = false, activeSubInstruction: String = "") {
        self.stepNumber = stepNumber
        self.mainInstruction = mainInstruction
        self.subInstructions = subInstructions
        self.isCurrent = isCurrent
        self.activeSubInstruction = activeSubInstruction
        self._isExpanded = State(initialValue: isCurrent && !subInstructions.isEmpty)
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(subInstructions.indices, id: \.self) { index in
                    Divider()
                        .padding(.horizontal, 16)
                    
                    let isActiveSub = subInstructions[index] == activeSubInstruction
                    
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(isActiveSub ? (Color.ovalGreen ?? .green) : Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                            .padding(.top, 8)
                        
                        Text(subInstructions[index])
                            .font(.subheadline)
                            .foregroundStyle(isActiveSub ? .primary : .secondary)
                            .fontWeight(isActiveSub ? .bold : .regular)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
        } label: {
            Text(mainInstruction)
        }
        .disclosureGroupStyle(DisclosureStyle(stepNumber: stepNumber, isCurrent: isCurrent, hasSubInstructions: !subInstructions.isEmpty))
        .onChange(of: isCurrent) { _, newValue in
            if newValue && !subInstructions.isEmpty {
                withAnimation {
                    isExpanded = true
                }
            }
        }
    }
}

#Preview {
    InstructionDetailCard(
        stepNumber: 2,
        mainInstruction: "Bersihkan ayam, lalu masukan bumbu halus juga bumbu marinasi. Aduk rata.",
        subInstructions: [
            "Bersihkan ayam.",
            "Masukan bumbu halus juga bumbu marinasi.",
            "Aduk rata."
        ],
        isCurrent: true
    )
}
