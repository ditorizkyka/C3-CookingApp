//
//  RecipeLibrary.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct RecipeLibrary: View {
    enum SortOption {
        case name
        case dateAdded
    }
    
    @State private var searchRecipe = ""
    @State private var sortOption: SortOption = .name
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var filteredRecipes: [Recipe] {
        var result = Recipe.dummyRecipes
        
        if !searchRecipe.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchRecipe) }
        }
        
        switch sortOption {
        case .name:
            result.sort { $0.title < $1.title }
        case .dateAdded:
            break
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredRecipes.indices, id: \.self) { index in
                        let recipe = filteredRecipes[index]
                        let colors: [Color] = [.recipeCardBronze ?? .orange, .recipeCardCyan ?? .cyan, .recipeCardGreen ?? .green, .recipeCardPurple ?? .purple, .recipeCardRed ?? .red]
                        let color = colors[index % colors.count]
                        
                        RecipeCardSmall(
                            recipeTitle: recipe.title,
                            recipeCategoryIcon: "🍲",
                            recipeImage: "img_test",
                            recipeColor: color,
                            recipePortion: recipe.portion,
                            recipeDuration: recipe.durationInMinutes
                        )
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Semua Resep")
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            sortOption = .name
                        } label: {
                            HStack {
                                Text("Name")
                                if sortOption == .name {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button {
                            sortOption = .dateAdded
                        } label: {
                            HStack {
                                Text("Date Added")
                                if sortOption == .dateAdded {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .searchable(
                text: $searchRecipe,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Cari resep..."
            )
        }
    }
}

#Preview {
    RecipeLibrary()
}
