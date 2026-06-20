import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
enum ArticleExtractorError: LocalizedError {
    case appleIntelligenceUnavailable
    case noRecipeContentFound

    var errorDescription: String? {
        switch self {
        case .appleIntelligenceUnavailable:
            return "Apple Intelligence is not available on this device. Requires iPhone 15 Pro or later running iOS 18.1+."
        case .noRecipeContentFound:
            return "No recipe content (ingredients or instructions) could be found in this article."
        }
    }
}
#endif
