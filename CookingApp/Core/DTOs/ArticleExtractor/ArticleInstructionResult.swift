import Foundation

#if canImport(FoundationModels)
import FoundationModels

/// Represents one extracted instruction step from an article
@available(iOS 26.0, *)
@Generable
struct ArticleInstructionResult {
    @Guide(description: "A single cooking instruction step from the recipe article. Must be one complete, actionable command. Example: 'Tumis bawang putih dan bawang merah hingga harum.' or 'Preheat oven to 180 degrees Celsius.'")
    var text: String
}
#endif
