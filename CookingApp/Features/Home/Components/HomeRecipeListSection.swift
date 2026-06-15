//
//  HomeRecipeListSection.swift
//  CookingApp
//

import SwiftUI

struct HomeRecipeListSection: View {
    @ObservedObject var viewModel: HomeViewModel
    let allRecipes: [Recipe]
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Resep")
                    .font(Font.headline)
                    .foregroundStyle(Color.labelLight!)
                
                Spacer()
                
                Button {
                    viewModel.navigateToLibrary = true
                } label: {
                    Text("Lihat Semua")
                        .font(Font.subheadline)
                        .foregroundStyle(Color.brandAccent!)
                }
            }
            .padding(.horizontal, 14)
            
            if !allRecipes.isEmpty {
                ScrollView {
                    VStack(spacing: -120) {
                        ForEach(allRecipes.prefix(6).indices, id: \.self) { index in
                            let isSelected = viewModel.selectedIndex == index
                            let recipe = allRecipes[index]
                            let colors: [Color] = [.recipeCardBronze ?? .orange, .recipeCardCyan ?? .cyan, .recipeCardGreen ?? .green, .recipeCardPurple ?? .purple, .recipeCardRed ?? .red]
                            let color = colors[index % colors.count]
                            
                            RecipeCard(
                                recipeTitle: recipe.title,
                                recipeCategoryIcon: "🍲",
                                imageName: nil,
                                imageUrl: recipe.coverImageUrl,
                                imageData: recipe.coverImageData,
                                recipeColor: color,
                                recipePortion: recipe.portion,
                                recipeDuration: recipe.durationInMinutes
                            )
                            .zIndex(Double(index))
                            .brightness(!isSelected ? -Double(allRecipes.count - index) * 0.02 : 0)
                            .padding(.top, viewModel.selectedIndex != nil && index == viewModel.selectedIndex! + 1 ? 160 : 0)
                            .onTapGesture {
                                if viewModel.selectedIndex == index {
                                    viewModel.navigateToDetail = true
                                } else {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                                        viewModel.selectedIndex = index
                                    }
                                }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.large))
                
            } else {
                HomeEmptyStateCard()
            }
            
            Spacer()
        }
    }
}
