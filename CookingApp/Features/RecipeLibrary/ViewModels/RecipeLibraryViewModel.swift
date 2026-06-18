//
//  RecipeLibraryViewModel.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

class RecipeLibraryViewModel: ObservableObject {
    enum SortOption {
        case name
        case dateAdded
    }
    
    @Published var searchRecipe = ""
    @Published var sortOption: SortOption = .name
    @Published var selectedIndex: Int? = nil
    @Published var navigateToDetail = false
    
    @Published var recipeToDelete: Recipe? = nil
    @Published var showDeleteConfirmation = false
    
    func confirmDelete(recipe: Recipe) {
        recipeToDelete = recipe
        showDeleteConfirmation = true
    }
    
    func deleteRecipe(context: SwiftData.ModelContext) {
        if let recipe = recipeToDelete {
            context.delete(recipe)
            try? context.save()
            recipeToDelete = nil
        }
    }
    
    func getFilteredRecipes(from allRecipes: [Recipe]) -> [Recipe] {
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
    
    func selectRecipe(recipe: Recipe, in filteredRecipes: [Recipe]) {
        if let index = filteredRecipes.firstIndex(where: { $0.id == recipe.id }) {
            selectedIndex = index
            navigateToDetail = true
        }
    }
    
    func dismissDetail() {
        navigateToDetail = false
    }
}
