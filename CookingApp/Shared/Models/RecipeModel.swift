//
//  Recipe.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//


import Foundation

// MARK: - Recipe
struct Recipe: Identifiable, Codable {
    let id: UUID
    var title: String
    var author: Author
    var coverImageUrl: URL?
    var portion: Int
    var durationInMinutes: Int
    var ingredients: [Ingredient]
    var instructions: [Instruction]
    var tips: String?
}

// MARK: - Author
struct Author: Identifiable, Codable {
    let id: UUID
    var name: String
    var username: String
    var avatarUrl: URL?
}


// MARK: - Ingredient
struct Ingredient: Identifiable, Codable {
    var id: UUID
    var quantity: String
    var name: String
    var groupIngredients: [Ingredient]?
    
    var isGroup: Bool {
        return groupIngredients != nil && !(groupIngredients?.isEmpty ?? true)
    }
}

// MARK: - Instruction
struct Instruction: Identifiable, Codable {
    let id: UUID
    var sequenceNumber: Int
    var text: String
    var photoUrl: URL?
    var breakdownInstruction: [Instruction]
}
