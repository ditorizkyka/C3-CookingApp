import Foundation

#if canImport(FoundationModels)
import FoundationModels

/// Used for translating the extracted recipe EN -> ID
@available(iOS 26.0, *)
@Generable
struct TranslatedRecipeResult {
    @Guide(description: "The translated list of ingredients in Indonesian. Preserve exact measurements.")
    var indonesianIngredients: [String]

    @Guide(description: "The translated list of cooking instructions in Indonesian.")
    var indonesianInstructions: [String]
}
#endif
