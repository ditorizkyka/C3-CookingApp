import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.1, *)
@Generable
struct ArticleExtractionPayload {
    @Guide(description: "A list of ingredient groups. If there are no groups, put all ingredients in a single group with an empty groupName.")
    var ingredientGroups: [ArticleIngredientGroup]
    
    @Guide(description: "A list of strings representing the step-by-step cooking instructions. Extract exactly as written in the text.")
    var instructions: [String]
    
    @Guide(description: "A string representing the name or title of the recipe. If not explicitly found, try to guess from context or return 'Resep Tanpa Judul'.")
    var recipeName: String
}
#endif
