//
//  HomeView.swift
//  CookingApp
//
//  Created by Brian Anashari on 06/06/26.
//

import SwiftUI

let mockRecipes: [RecipeCard] = [
    RecipeCard(recipeTitle: "Ayam Tepung Kriuk Sambal", recipeCategoryIcon: "🎂", recipeImage: "img_test", recipeColor: Color.recipeCardBronze!),
    
    RecipeCard(recipeTitle: "Ayam Tepung Kriuk Sambal", recipeCategoryIcon: "🎂", recipeImage: "img_test", recipeColor: Color.recipeCardCyan!),
    
    RecipeCard(recipeTitle: "Ayam Tepung Kriuk Sambal", recipeCategoryIcon: "🎂", recipeImage: "img_test", recipeColor: Color.recipeCardGreen!),
    
    RecipeCard(recipeTitle: "Ayam Tepung Kriuk Sambal", recipeCategoryIcon: "🎂", recipeImage: "img_test", recipeColor: Color.recipeCardPurple!),
    
    RecipeCard(recipeTitle: "Ayam Tepung Kriuk Sambal", recipeCategoryIcon: "🎂", recipeImage: "img_test", recipeColor: Color.recipeCardRed!)
]

struct HomeView: View {
    @State private var searchRecipe: String = ""
    @State private var selectedIndex: Int? = nil
    @State private var allRecipes: [RecipeCard] = mockRecipes
    
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
                    
                    if !allRecipes.isEmpty {
                        ScrollView {
                            VStack(spacing: -120) {
                                ForEach(mockRecipes.indices, id: \.self) { index in
                                    let isSelected = selectedIndex == index
                                    
                                    mockRecipes[index]
                                        .zIndex(Double(index))
                                    //                                    .scaleEffect(!isSelected ? 1.0 - (CGFloat(mockRecipes.count - index) * 0.01) : 1.0)
                                        .brightness(!isSelected ? -Double(mockRecipes.count - index) * 0.02 : 0)
                                    
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
