//
//  HomeView.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI

// Mock recipes removed in favor of Recipe.dummyRecipes

struct HomeView: View {
    @State private var searchRecipe: String = ""
    @State private var selectedIndex: Int? = nil
    @State private var allRecipes: [Recipe] = Recipe.dummyRecipes
    
    // 1. TAMBAHKAN STATE INI
    @State private var navigateToManual = false
    
    @State private var isShowingImportSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                // Add Recipe Button
                HStack() {
                    AddRecipeButton(isManual: false, titleButton: "Import Resep", descriptionButton: "Tambahkan resep dari link website",
                                    action: {
                        isShowingImportSheet = true
                    })
                    AddRecipeButton(isManual: true, titleButton: "Tulis Resep", descriptionButton: "Buat dan simpan resepmu",
                                    action: {
                        navigateToManual = true
                        
                    })
                    
                }
                .padding(.horizontal)
                
                // Recipe Section
                VStack(spacing: 16) {
                    // Title
                    HStack {
                        Text("Resep")
                            .font(Font.headline)
                            .foregroundStyle(Color.labelLight!)
                        
                        Spacer()
                        
                        Button {
                            print("Lihat Semua")
                        } label: {
                            Text("Lihat Semua")
                                .font(Font.subheadline)
                                .foregroundStyle(Color.brandAccent!)
                        }
                    }
                    .padding(.horizontal,14)
                    
                    if !allRecipes.isEmpty {
                        ScrollView {
                            VStack(spacing: -120) {
                                ForEach(allRecipes.indices, id: \.self) { index in
                                    let isSelected = selectedIndex == index
                                    let recipe = allRecipes[index]
                                    let colors: [Color] = [.recipeCardBronze ?? .orange, .recipeCardCyan ?? .cyan, .recipeCardGreen ?? .green, .recipeCardPurple ?? .purple, .recipeCardRed ?? .red]
                                    let color = colors[index % colors.count]
                                    
                                    RecipeCard(
                                        recipeTitle: recipe.title,
                                        recipeCategoryIcon: "🍲",
                                        recipeImage: "img_test",
                                        recipeColor: color,
                                        recipePortion: recipe.portion,
                                        recipeDuration: recipe.durationInMinutes
                                    )
                                        .zIndex(Double(index))
                                        .brightness(!isSelected ? -Double(allRecipes.count - index) * 0.02 : 0)
                                        .padding(.top, selectedIndex != nil && index == selectedIndex! + 1 ? 160 : 0)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                                                if selectedIndex == index {
                                                    selectedIndex = nil
                                                } else {
                                                    selectedIndex = index
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
                .sheet(isPresented: $isShowingImportSheet) {
                    ImportRecipeSheet()
                        .presentationDetents([.fraction(0.5), .large])
                        .presentationDragIndicator(.visible)
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
                .frame(maxHeight: .infinity)
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.xLarge))
                .ignoresSafeArea()
                
                
                
            }
            
            .background(Color.surfaceBrand.ignoresSafeArea())
            .searchable(
                text: $searchRecipe,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Cari resep..."
            )
            .searchDictationBehavior(.inline(activation: .onSelect))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToManual) {
                AddManualRecipeView()
            }
            
            
            
            
        }
    }
}

#Preview {
    HomeView()
}
