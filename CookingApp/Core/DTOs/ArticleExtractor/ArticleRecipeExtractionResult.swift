import Foundation

#if canImport(FoundationModels)
import FoundationModels

/// The full structured extraction result returned by the Foundation Model
@available(iOS 26.0, *)
@Generable
struct ArticleRecipeExtractionResult {
    @Guide(description: "The name/title of the recipe extracted from the article text. If not found, return an empty string.")
    var recipeName: String

    @Guide(description: "All ingredient lines found in the article. Each item must be a distinct ingredient with its quantity and unit. Do NOT include cooking steps, blog stories, health tips, or navigation text as ingredients.")
    var ingredients: [ArticleIngredientResult]

    @Guide(description: "All cooking instruction steps found in the article, in the correct order. Each item must be one complete cooking action. Do NOT include ingredient lists, blog stories, health tips, or navigation text as instructions.")
    var instructions: [ArticleInstructionResult]
}
#endif
