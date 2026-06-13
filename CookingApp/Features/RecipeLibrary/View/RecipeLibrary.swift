//
//  RecipeLibrary.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI
import SwiftData

struct RecipeLibrary: View {
    enum SortOption {
        case name
        case dateAdded
    }
    
    @Query private var allRecipes: [Recipe]
    @State private var searchRecipe = ""
    @State private var sortOption: SortOption = .name
    @State private var selectedIndex: Int? = nil
    @State private var navigateToDetail = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var filteredRecipes: [Recipe] {
        var result = allRecipes
        
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
        RecipeGridSearchResultView(
            searchQuery: searchRecipe,
            filteredRecipes: filteredRecipes,
            onTapRecipe: { recipe in
                if let index = filteredRecipes.firstIndex(where: { $0.id == recipe.id }) {
                    selectedIndex = index
                    navigateToDetail = true
                }
            }
        )
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
            .navigationDestination(isPresented: $navigateToDetail) {
                if let index = selectedIndex, index < filteredRecipes.count {
                    let selectedRecipe = filteredRecipes[index]
                    DetailRecipeView(recipe: selectedRecipe, onDismiss: { navigateToDetail = false })
                }
            }
    }
}

#Preview {
    NavigationStack {
        RecipeLibrary()
    }
    .modelContainer(PreviewContainer.shared)
}
