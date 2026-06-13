//
//  DummyData.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//

import Foundation
import SwiftData

// MARK: - Sample data factory
// NOTE: @Model objects (Recipe, Ingredient, Instruction, Author) must live in a ModelContext.
// Use PreviewContainer.shared for previews and the app's modelContainer for production.
// The helper below creates a standalone in-memory container and returns sample recipes
// that are already inserted — safe to use in places that truly need a [Recipe] array.

extension Recipe {
    
    @MainActor
    static var dummyRecipes: [Recipe] {
        // Return the recipes that PreviewContainer.shared already inserted
        let ctx = PreviewContainer.shared.mainContext
        let descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.title)])
        return (try? ctx.fetch(descriptor)) ?? []
    }
}
