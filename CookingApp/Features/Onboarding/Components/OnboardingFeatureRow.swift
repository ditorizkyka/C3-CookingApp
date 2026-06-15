//
//  OnboardingFeatureRow.swift
//  CookingApp
//
//  Created by Brian Anashari on 09/06/26.
//

import SwiftUI

struct OnboardingFeatureRow: View {
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: iconName)
                .font(Font.title)
                .foregroundStyle(Color.brandAccent!)
                .padding()
                .background(Color.labelLight!.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            
            // Detail
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(title)
                    .font(Font.headline)
                
                // Description
                Text(description)
                    .font(Font.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
