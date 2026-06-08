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
    
    @State private var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(subInstructions.indices, id: \.self) { index in
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                            .padding(.top, 8)
                        
                        Text(subInstructions[index])
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
        } label: {
            Text(mainInstruction)
        }
        .disclosureGroupStyle(DisclosureStyle(stepNumber: stepNumber))
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
        ]
    )
}
