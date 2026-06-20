import Foundation

#if canImport(FoundationModels)
import FoundationModels

/// Represents one extracted ingredient line from an article
@available(iOS 26.0, *)
@Generable
struct ArticleIngredientResult {
    @Guide(description: "A single ingredient line from the recipe article. Must include quantity and food item if present. Example: '500 gram daging sapi' or '2 siung bawang putih'.")
    var text: String
}
#endif
