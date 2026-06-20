import Foundation

#if canImport(FoundationModels)
import FoundationModels

/// Used for translating the raw batch ID -> EN
@available(iOS 26.0, *)
@Generable
struct TranslationToEnglishResult {
    @Guide(description: "The English translation of the provided text. If the text is already in English, return it exactly as is.")
    var englishText: String
}
#endif
