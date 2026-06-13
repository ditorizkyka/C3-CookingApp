//
//  RecipeValidator.swift
//  CookingApp
//
//  Shared empty-field validation for the recipe editors (Add Manual & Detail edit).
//  Every field must be filled in before a recipe can be saved.
//

import Foundation

enum RecipeValidator {

    /// Returns `nil` when the recipe is valid, otherwise a human-readable
    /// (Indonesian) message describing the first problem found.
    static func validate(
        title: String,
        ingredients: [Ingredient],
        instructions: [Instruction]
    ) -> String? {
        if isBlank(title) {
            return "Nama resep belum diisi."
        }

        guard !ingredients.isEmpty else {
            return "Tambahkan minimal satu bahan."
        }

        for ingredient in ingredients {
            // `isGroup` is true only when groupIngredients is non-nil AND non-empty.
            // A single ingredient (incl. one whose optional relationship SwiftData
            // materialized as an empty array) is validated as a single — name + qty.
            if ingredient.isGroup {
                // Group row: needs a group name and every member filled in.
                if isBlank(ingredient.name) {
                    return "Nama grup bahan belum diisi."
                }
                for sub in ingredient.groupIngredients ?? [] {
                    if isBlank(sub.quantity) || isBlank(sub.name) {
                        return "Lengkapi jumlah dan nama untuk setiap bahan."
                    }
                }
            } else {
                if isBlank(ingredient.quantity) || isBlank(ingredient.name) {
                    return "Lengkapi jumlah dan nama untuk setiap bahan."
                }
            }
        }

        guard !instructions.isEmpty else {
            return "Tambahkan minimal satu langkah."
        }

        for instruction in instructions {
            if isBlank(instruction.text) {
                return "Lengkapi teks untuk setiap langkah."
            }
            for sub in instruction.breakdownInstruction where isBlank(sub.text) {
                return "Lengkapi teks untuk setiap sub-langkah."
            }
        }

        return nil
    }

    private static func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
