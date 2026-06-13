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
    @Published var isEdited: Bool = false

    // Validation feedback (surfaced as an alert by the view).
    @Published var showValidationAlert: Bool = false
    @Published var validationMessage: String = ""

    /// Value snapshot captured when editing begins, used to revert on "Buang".
    private var snapshot: RecipeSnapshot?

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    // MARK: - Edit Lifecycle

    func beginEditing() {
        snapshot = makeSnapshot()
        withAnimation { isEdited = true }
    }

    /// Validate and leave edit mode. Returns `false` (and shows the validation
    /// alert) when a field is empty, so the caller can keep the user editing.
    @discardableResult
    func commitEditing() -> Bool {
        if let message = RecipeValidator.validate(
            title: recipe.title,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions
        ) {
            validationMessage = message
            showValidationAlert = true
            return false
        }
        renumberInstructions()
        snapshot = nil
        withAnimation { isEdited = false }
        return true
    }

    /// Discard all edits made since `beginEditing()` and leave edit mode.
    func cancelEditing() {
        if let snapshot {
            restore(from: snapshot)
        }
        snapshot = nil
        withAnimation { isEdited = false }
    }

    // MARK: - Ingredient Mutations
    //
    // All deletions are done by object identity (id) instead of array index.
    // Index-based removal combined with `ForEach(array.indices)` is what caused
    // the "Index out of range" crashes: a captured index could outlive the item
    // it pointed to after the array shrank.

    func addIngredient() {
        recipe.ingredients.append(Ingredient(quantity: "", name: ""))
    }

    func addIngredientGroup() {
        recipe.ingredients.append(
            Ingredient(quantity: "", name: "", groupIngredients: [Ingredient(quantity: "", name: "")])
        )
    }

    func deleteIngredient(_ ingredient: Ingredient) {
        recipe.ingredients.removeAll { $0.id == ingredient.id }
    }

    func deleteSubIngredient(from group: Ingredient, sub: Ingredient) {
        group.groupIngredients?.removeAll { $0.id == sub.id }
    }

    // MARK: - Instruction Mutations

    func addInstruction() {
        let new = Instruction(
            sequenceNumber: recipe.instructions.count + 1,
            text: "",
            breakdownInstruction: []
        )
        recipe.instructions.append(new)
    }

    func deleteInstruction(_ instruction: Instruction) {
        recipe.instructions.removeAll { $0.id == instruction.id }
        renumberInstructions()
    }

    func deleteBreakdown(from instruction: Instruction, sub: Instruction) {
        instruction.breakdownInstruction.removeAll { $0.id == sub.id }
    }

    /// Keep `sequenceNumber` aligned with the visual top-to-bottom order (1, 2, 3, …)
    /// so cooking mode and any stored numbering stay consistent after edits.
    func renumberInstructions() {
        for (index, instruction) in recipe.instructions.enumerated() {
            instruction.sequenceNumber = index + 1
        }
    }

    // MARK: - Snapshot helpers

    private func makeSnapshot() -> RecipeSnapshot {
        RecipeSnapshot(
            title: recipe.title,
            portion: recipe.portion,
            durationInMinutes: recipe.durationInMinutes,
            ingredients: recipe.ingredients.map { IngredientSnapshot($0) },
            instructions: recipe.instructions.map { InstructionSnapshot($0) }
        )
    }

    private func restore(from snapshot: RecipeSnapshot) {
        recipe.title = snapshot.title
        recipe.portion = snapshot.portion
        recipe.durationInMinutes = snapshot.durationInMinutes
        // Rebuild the relationships from value copies; SwiftData cascades the
        // delete of the edited objects and inserts these fresh ones.
        recipe.ingredients = snapshot.ingredients.map { $0.build() }
        recipe.instructions = snapshot.instructions.map { $0.build() }
    }
}

// MARK: - Value Snapshots (plain structs, decoupled from SwiftData)

struct RecipeSnapshot {
    var title: String
    var portion: Int
    var durationInMinutes: Int
    var ingredients: [IngredientSnapshot]
    var instructions: [InstructionSnapshot]
}

struct IngredientSnapshot {
    var quantity: String
    var name: String
    var group: [IngredientSnapshot]?

    /// `captureMembers` is true only at the top level so we descend AT MOST one
    /// level. `Ingredient.groupIngredients` is a self-referential SwiftData
    /// relationship with no explicit inverse, so the graph it returns can be
    /// cyclic (a member's `groupIngredients` points back into its own group).
    /// Recursing into members would loop forever and overflow the stack.
    init(_ ingredient: Ingredient, captureMembers: Bool = true) {
        self.quantity = ingredient.quantity
        self.name = ingredient.name
        if captureMembers, ingredient.isGroup, let members = ingredient.groupIngredients {
            self.group = members.map { IngredientSnapshot($0, captureMembers: false) }
        } else {
            self.group = nil
        }
    }

    func build() -> Ingredient {
        Ingredient(
            quantity: quantity,
            name: name,
            groupIngredients: group?.map { $0.build() }
        )
    }
}

struct InstructionSnapshot {
    var sequenceNumber: Int
    var text: String
    var breakdown: [InstructionSnapshot]

    /// Capture at most one level of breakdown sub-steps — `breakdownInstruction`
    /// is also a self-referential relationship that can be cyclic.
    init(_ instruction: Instruction, captureBreakdown: Bool = true) {
        self.sequenceNumber = instruction.sequenceNumber
        self.text = instruction.text
        if captureBreakdown {
            self.breakdown = instruction.breakdownInstruction.map { InstructionSnapshot($0, captureBreakdown: false) }
        } else {
            self.breakdown = []
        }
    }

    func build() -> Instruction {
        Instruction(
            sequenceNumber: sequenceNumber,
            text: text,
            breakdownInstruction: breakdown.map { $0.build() }
        )
    }
}
