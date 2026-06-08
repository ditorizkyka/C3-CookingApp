//
//  CustomDisclosureStyle.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct DisclosureStyle: DisclosureGroupStyle {
    let stepNumber: Int
    
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
                    Image(systemName: configuration.isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.brandPrimary ?? .green)
                }
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
                .stroke(Color.brandPrimary ?? .green, lineWidth: 2)
        )
    }
}
