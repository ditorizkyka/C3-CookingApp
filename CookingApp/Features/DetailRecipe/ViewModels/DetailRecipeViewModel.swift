//
//  DetailRecipeViewModels.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 09/06/26.
//

import Foundation
import SwiftUI
import Combine

class DetailRecipeViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var isEdited : Bool = false
    
    init(recipe: Recipe) {
            self.recipe = recipe
    }
    
    // MARK: - Intent (Fungsi Logika)
    func toggleEditMode() {
        withAnimation {
            isEdited.toggle()
        }
    }
    
    // MARK: - Ingredient Mutations
    func deleteIngredient(at offsets: IndexSet) {
        recipe.ingredients.remove(atOffsets: offsets)
    }
    
    func deleteInstruction(at offsets: IndexSet) {
        recipe.instructions.remove(atOffsets: offsets)
    }
    
    func deleteSubIngredient(parentIndex: Int, at offsets: IndexSet) {
        recipe.ingredients[parentIndex].groupIngredients?.remove(atOffsets: offsets)
    }
}
