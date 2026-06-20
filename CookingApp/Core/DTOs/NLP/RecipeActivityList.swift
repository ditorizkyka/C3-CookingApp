import Foundation
import FoundationModels

@available(iOS 18.1, *)
@Generable
struct RecipeActivityList {
    @Guide(description: "A list of individual cooking activity steps extracted from the recipe instruction. Each step must be a single, actionable cooking command.")
    var steps: [String]
}
