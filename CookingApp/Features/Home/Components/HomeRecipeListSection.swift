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
                            .scaleEffect(isSelected ? 1.03 : 1.0)
                            .offset(y: isSelected ? -10 : 0)
                            .brightness(viewModel.selectedIndex != nil ? (isSelected ? 0.05 : -Double(allRecipes.count - index) * 0.02 - 0.2) : -Double(allRecipes.count - index) * 0.02)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.selectedIndex != nil {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                                viewModel.selectedIndex = nil
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
        .overlay(alignment: .bottom) {
            if viewModel.selectedIndex != nil {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                        viewModel.selectedIndex = nil
                    }
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Tutup")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.surfaceDefault!)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.labelDark!.opacity(0.8))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
