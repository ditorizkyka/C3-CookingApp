//
//  RecipeCard.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI

struct RecipeCard: View {
    var recipeTitle: String
    var recipeCategoryIcon: String
    var recipeImage: String
    var recipeColor: Color
    var recipePortion: Int
    var recipeDuration: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title
            HStack {
                Text(recipeTitle)
                    .font(Font.headline)
                    .foregroundStyle(Color.labelLightest!)
                    .lineLimit(2)
                
                Spacer()
                
                Text(recipeCategoryIcon)
                    .font(Font.body)
                    .padding(4)
                    .background(Color.labelLightest.opacity(0.3))
                    .cornerRadius(Radius.infinity)
            }
            
            Spacer()
            
            // Chip
            HStack(spacing: 4) {
                // Total Serving
                HStack(spacing: 2) {
                    Image(systemName: "person.2.fill")
                    Text("\(recipePortion)")
                }
                
                // Time Serving
                HStack(spacing: 2) {
                    Image(systemName: "clock.fill")
                    Text("\(recipeDuration) min")
                }
            }
            .font(Font.footnote)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .glassEffect()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 150)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            ZStack() {
                Image(recipeImage)
                    .resizable()
                    .scaledToFill()
                
                LinearGradient(
                    colors: [recipeColor, recipeColor.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(Color.surfaceElevated ?? .gray, lineWidth: 1.5)
        )
        
    }
}

#Preview {
    RecipeCard(recipeTitle: "Ayam Tepung Kriuk Sambal", recipeCategoryIcon: "🎂", recipeImage: "img_test", recipeColor: Color.red, recipePortion: 4, recipeDuration: 30)
}
