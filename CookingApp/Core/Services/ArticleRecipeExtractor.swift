import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.2, *)
struct ArticleRecipeExtractor {

    func extractRecipe(
        from rawText: String,
        title: String = ""
    ) async throws -> (ingredientGroups: [ArticleIngredientGroup], instructions: [String], recipeName: String) {

        guard case .available = SystemLanguageModel.default.availability else {
            throw ArticleExtractorError.appleIntelligenceUnavailable
        }

        print("\n" + String(repeating: "=", count: 60))
        print("📰 ARTICLE RECIPE EXTRACTOR v2 — Heuristic + AI")
        print(String(repeating: "=", count: 60))
        print("📄 Raw text length: \(rawText.count) characters")

        // Step 1: Heuristic Section Extraction (Filter out medical/blog text)
        let relevantText = extractRelevantSections(from: rawText)
        print("✂️ Filtered text length: \(relevantText.count) characters")
        print(String(repeating: "-", count: 60))

        if relevantText.isEmpty {
            return ([], [], "")
        }

        // Step 2: Extract directly using Apple Intelligence (Single Pass)
        let session = LanguageModelSession()
        let prompt = """
        You are a PRECISION recipe data extractor.
        Extract the recipe ingredients and step-by-step cooking instructions from the text below.
        
        CRITICAL RULES:
        1. Extract the data exactly as written in the original language (Indonesian or English). Do NOT translate.
        2. Group the ingredients EXACTLY as they are grouped in the text.
           - If an ingredient is NOT under any specific sub-group, or if it is under a generic header like "Bahan-bahan", "Bahan", "Bahan Utama", or "Ingredients", you MUST set its `groupName` to an empty string `""`.
           - If the text explicitly splits ingredients into sub-groups (e.g., "Bumbu Halus", "Bahan Kuah", "Topping"), use those exact names for `groupName`.
           - STRICTLY PROHIBITED: Do NOT use "Bahan-bahan", "Bahan", "Bahan Utama", "Ingredients", or "Group 1" as a `groupName`. Use `""` instead.
        3. Ignore all medical advice, blog stories, unrelated articles, and author commentary.
        4. If there are no clear ingredients or instructions, return empty arrays.
        5. For the `recipeName` field: Generate a CLEAN, short, and accurate recipe name based on the text (e.g., instead of "Daftar Resep Ayam Rica Rica, Cocok untuk Menu Makan Siang", just return "Ayam Rica Rica").

        === RELEVANT TEXT ===
        \(relevantText)
        """

        print("🤖 Processing with Apple Intelligence...")

        let response = try await session.respond(
            to: prompt,
            generating: ArticleExtractionPayload.self
        )

        let result = response.content

        // Step 3: Deduplicate
        let ingredientGroups = result.ingredientGroups
        let uniqueInstructions = deduplicate(result.instructions)
        let recipeName = result.recipeName.isEmpty ? "Resep Tanpa Judul" : result.recipeName

        print("\n" + String(repeating: "=", count: 60))
        print("✅ ARTICLE EXTRACTION COMPLETE")
        print(String(repeating: "=", count: 60))
        print("📖 Recipe Name: \(recipeName)")
        print("🥕 INGREDIENTS (\(ingredientGroups.count) groups):")
        for (idx, group) in ingredientGroups.enumerated() {
            let prefix = group.groupName.isEmpty ? "Flat" : "Group '\(group.groupName)'"
            print("  [\(idx + 1)] \(prefix): \(group.ingredients.count) items")
            for item in group.ingredients {
                print("      - \(item)")
            }
        }
        print("📋 INSTRUCTIONS (\(uniqueInstructions.count)):")
        uniqueInstructions.enumerated().forEach { i, s in print("  [\(i+1)] \(s)") }
        print(String(repeating: "=", count: 60) + "\n")

        return (
            ingredientGroups: ingredientGroups,
            instructions: uniqueInstructions,
            recipeName: recipeName
        )
    }

    // =========================================================================
    // MARK: - Heuristic Section Extractor
    // =========================================================================

    private func extractRelevantSections(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let ingredientKeywords = ["bahan", "bumbu", "ingredients", "yang dibutuhkan", "siapkan"]
        let instructionKeywords = ["cara", "langkah", "instruksi", "steps", "directions", "membuat", "pembuatan"]
        let stopKeywords = ["resep serupa", "komentar", "leave a reply", "you might also like", "similar recipes", "comments", "sign up", "subscribe", "related posts", "post navigation"]
        
        var isCapturing = false
        var capturedLines: [String] = []
        var linesSinceLastValid = 0
        
        for line in lines {
            guard !line.isEmpty else { continue }
            
            let lowerLine = line.lowercased()
            
            // Check if this line is a header containing a keyword
            let isHeader = line.count < 50
            let containsIngredient = ingredientKeywords.contains(where: { lowerLine.contains($0) })
            let containsInstruction = instructionKeywords.contains(where: { lowerLine.contains($0) })
            let isStopKeyword = stopKeywords.contains(where: { lowerLine == $0 || lowerLine.starts(with: $0) })
            
            if isStopKeyword {
                isCapturing = false
                break // Stop processing entirely, we hit the footer section
            }
            
            if isHeader && (containsIngredient || containsInstruction) {
                isCapturing = true
                linesSinceLastValid = 0
                capturedLines.append("--- " + line.uppercased() + " ---")
                continue
            }
            
            if isCapturing {
                // If it looks like a list item or a short sentence, keep capturing
                let isListItem = line.hasPrefix("-") || line.hasPrefix("•") || line.hasPrefix("*") || Int(String(line.prefix(1))) != nil
                let isShortSentence = line.count < 150
                
                if isListItem || isShortSentence {
                    capturedLines.append(line)
                    linesSinceLastValid = 0
                } else {
                    linesSinceLastValid += 1
                    // If we see 3 long paragraphs of blog story in a row, stop capturing this block
                    if linesSinceLastValid > 3 {
                        isCapturing = false
                    } else {
                        // Still capture it just in case
                        capturedLines.append(line)
                    }
                }
            }
        }
        
        // If heuristic fails completely (e.g. no headers found), return the raw text but truncated to prevent LLM overload
        if capturedLines.isEmpty {
            return String(text.prefix(4000))
        }
        
        return capturedLines.joined(separator: "\n")
    }

    // =========================================================================
    // MARK: - Deduplication Helper
    // =========================================================================

    private func deduplicate(_ items: [String]) -> [String] {
        var seen = Set<String>()
        return items.filter { item in
            let key = item.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { return false }
            return seen.insert(key).inserted
        }
    }
}
#endif
