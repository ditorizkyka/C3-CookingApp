//
//  CustomDisclosureStyle.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct DisclosureStyle: DisclosureGroupStyle {
    let stepNumber: Int
    var isCurrent: Bool = false
    var hasSubInstructions: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Label (Header)
            HStack(alignment: .top, spacing: 16) {
                Text("\(stepNumber)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 2)
                
                // Ini merepresentasikan `label` dari DisclosureGroup
                configuration.label
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(height: 60)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        configuration.isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: hasSubInstructions ? (configuration.isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill") : "chevron.down.circle")
                        .font(.title2)
                        .foregroundStyle(hasSubInstructions ? (Color.brandPrimary ?? .green) : Color.gray.opacity(0.5))
                }
                .disabled(!isCurrent || !hasSubInstructions)
                .padding(.top, 16)
            }
            .padding(16)
            
            // Content
            if configuration.isExpanded {
                configuration.content
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrent ? (Color.brandPrimary ?? .green) : Color.clear, lineWidth: 2)
        )
    }
}
