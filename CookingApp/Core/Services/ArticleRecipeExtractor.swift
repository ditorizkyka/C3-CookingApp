import Foundation
import NaturalLanguage

#if canImport(FoundationModels)
import FoundationModels

// =============================================================================
// MARK: - Article Recipe Extractor Service
// =============================================================================

@available(iOS 26.0, *)
struct ArticleRecipeExtractor {

    // =========================================================================
    // MARK: - Known Cooking Verbs (for prechunkWithTagger)
    // =========================================================================
    private let knownCookingVerbs: Set<String> = [
        // English
        "cook", "season", "preheat", "marinate", "chop", "add", "put", "pour",
        "peel", "slice", "knead", "drain", "mince", "mix", "combine", "grate",
        "cut", "dice", "blend", "beat", "whisk", "stir", "cover", "melt",
        "boil", "bake", "grill", "fry", "saute", "sauté", "roast", "steam",
        "simmer", "blanch", "broil", "poach", "braise", "remove", "heat",
        "serve", "prepare", "place", "set", "let", "wash", "rinse", "dry",
        "toast", "flip", "garnish", "taste", "adjust", "toss", "fold",
        "crush", "mash", "strain", "transfer", "rest", "sprinkle", "drizzle",
        "brush", "rub", "arrange", "divide", "refrigerate", "freeze",
        "thaw", "sear", "brown", "reduce", "thicken", "crack", "sift",
        "soak", "steep", "plate",
        // Indonesian
        "aduk", "goreng", "rebus", "masak", "potong", "iris", "campurkan",
        "tambahkan", "panaskan", "sajikan", "tuang", "tiriskan", "tumis",
        "kukus", "panggang", "haluskan", "ulek", "cincang", "rendam",
        "cuci", "kupas", "parut", "lumuri", "baluri", "sangrai", "oseng",
        "diamkan", "dinginkan", "angkat", "sisihkan", "hidangkan", "taburi",
        "siram", "oleskan", "ratakan", "masukkan", "didihkan", "kocok",
        "campur", "bumbui", "bakar", "taruh", "letakkan", "beri", "cicipi",
        "haluskan", "blender", "ungkep", "suwir", "belah"
    ]

    // =========================================================================
    // MARK: - Public API
    // =========================================================================

    /// Main entry point. Takes raw article page text and returns structured recipe data.
    /// - Parameters:
    ///   - rawText: The full visible text scraped from the article website.
    ///   - title: Optional title hint (used to help the model understand context).
    /// - Returns: Extracted ingredients and instructions in typed arrays.
    func extractRecipe(
        from rawText: String,
        title: String = ""
    ) async throws -> (ingredients: [String], instructions: [String], recipeName: String) {

        // Guard: Check that Apple Intelligence is available on this device
        guard case .available = SystemLanguageModel.default.availability else {
            throw ArticleExtractorError.appleIntelligenceUnavailable
        }

        // Step 1: Pre-chunk the raw text using NLTokenizer + NLTagger
        let chunks = prechunkArticleText(rawText)

        print("\n" + String(repeating: "=", count: 60))
        print("📰 ARTICLE RECIPE EXTRACTOR — Apple Foundation Model")
        print(String(repeating: "=", count: 60))
        print("📄 Raw text length: \(rawText.count) characters")
        print("🔪 Pre-chunked into \(chunks.count) segments")
        print(String(repeating: "-", count: 60))

        // Step 2 & 3: Process chunks in batches (max 5 chunks per prompt to avoid token limits)
        // Creating a new LanguageModelSession per batch prevents the context window from growing and exceeding the limit.
        let batchSize = 5
        var collectedIngredients: [ArticleIngredientResult] = []
        var collectedInstructions: [ArticleInstructionResult] = []
        var foundRecipeName = ""

        for batchStart in stride(from: 0, to: chunks.count, by: batchSize) {
            let session = LanguageModelSession()
            let batchEnd = min(batchStart + batchSize, chunks.count)
            let batch = chunks[batchStart..<batchEnd].joined(separator: "\n")

            // ================================================================
            // STEP 1: Translate Raw Batch (ID -> EN)
            // ================================================================
            let translatePrompt = """
            You are a professional translator. Translate the following text into English.
            If it is already in English, return it exactly as is.
            Preserve all numbers and measurements exactly.

            TEXT TO TRANSLATE:
            \(batch)
            """
            
            print("🌐 [Step 1] Translating batch \(batchStart/batchSize + 1)/\(Int(ceil(Double(chunks.count)/Double(batchSize)))) to English...")
            let enResponse = try await session.respond(to: translatePrompt, generating: TranslationToEnglishResult.self)
            let englishBatch = enResponse.content.englishText

            // ================================================================
            // STEP 2: Extract Recipe (from EN text)
            // ================================================================
            let prompt = """
            You are a PRECISION recipe data extractor. You MUST extract recipe ingredients and cooking instructions from messy article/blog text.

            === ARTICLE CONTEXT ===
            Title: "\(title.isEmpty ? "Unknown recipe article" : title)"
            Source: Blog/health/food article website (NOT a structured recipe site)
            Language: The text is in English.

            === YOUR EXACT TASK ===
            Read the TEXT BATCH below. For each line, decide if it is:
            (A) An INGREDIENT — add it to the ingredients list
            (B) A COOKING INSTRUCTION — add it to the instructions list
            (C) Neither — SKIP IT entirely (do NOT include it anywhere)

            === HOW TO IDENTIFY INGREDIENTS ===
            An ingredient line describes a FOOD ITEM, usually with a QUANTITY and UNIT.
            ✅ CORRECT ingredient examples:
            - "500 grams of beef"
            - "2 cloves of garlic, finely chopped"
            - "1 cup all-purpose flour"
            - "Salt and pepper to taste"
            - "• 4 kaffir lime leaves"
            - "1 tbsp cooking oil"
            - "3 eggs"

            ❌ These are NOT ingredients (do NOT include):
            - "Rawon is a traditional dish from East Java" (article description)
            - "Read Also: 10 Best Soup Recipes" (navigation link)
            - "Source: halodoc.com" (attribution)
            - "This recipe is very easy to make" (blog commentary)

            === HOW TO IDENTIFY INSTRUCTIONS ===
            An instruction line describes a COOKING ACTION that the cook must perform.
            It typically starts with or contains an imperative verb (a command).
            ✅ CORRECT instruction examples:
            - "Sauté the garlic and shallots until fragrant"
            - "Boil the meat for 1 hour until tender"
            - "Preheat the oven to 180°C"
            - "Add the ground spices to the broth"
            - "Serve the rawon with white rice and sambal"

            ❌ These are NOT instructions (do NOT include):
            - "Rawon has many health benefits" (health advice)
            - "This food is perfect for a diet" (opinion)
            - "Steps:" (section header only, no action)
            - "Ingredients:" (section header only, no content)

            === CRITICAL RULES ===
            1. If a line mixes story + recipe info, extract ONLY the recipe part.
            2. Section headers like "Ingredients:", "Steps:", "Directions:" are NOT ingredients or instructions — skip them.
            3. When in doubt, OMIT the line.
            4. If the batch contains NO recipe content at all, return empty arrays.

            === TEXT BATCH TO ANALYZE ===
            ---
            \(englishBatch)
            ---

            Extract the recipe data now.
            """

            print("🤖 [Step 2] Extracting recipe data from English batch...")

            let response = try await session.respond(
                to: prompt,
                generating: ArticleRecipeExtractionResult.self
            )

            let result = response.content

            if foundRecipeName.isEmpty && !result.recipeName.isEmpty {
                foundRecipeName = result.recipeName
            }
            
            // If nothing was extracted, skip translation back
            if result.ingredients.isEmpty && result.instructions.isEmpty {
                continue
            }

            // ================================================================
            // STEP 3: Translate Results Back (EN -> ID)
            // ================================================================
            let ingredientsText = result.ingredients.map { "- \($0.text)" }.joined(separator: "\n")
            let instructionsText = result.instructions.map { "- \($0.text)" }.joined(separator: "\n")
            
            let backTranslatePrompt = """
            You are a professional culinary translator. Translate the following cooking ingredients and instructions from English to Indonesian (Bahasa Indonesia).

            CRITICAL RULES:
            - Preserve all exact numbers, units, and measurements.
            - Ensure the translation sounds natural for Indonesian cooking.
            - Do NOT add any extra commentary. Output only the translated lists.

            INGREDIENTS TO TRANSLATE:
            \(ingredientsText.isEmpty ? "(None)" : ingredientsText)

            INSTRUCTIONS TO TRANSLATE:
            \(instructionsText.isEmpty ? "(None)" : instructionsText)
            """
            
            print("🇮🇩 [Step 3] Translating extracted results back to Indonesian...")
            let idResponse = try await session.respond(
                to: backTranslatePrompt,
                generating: TranslatedRecipeResult.self
            )
            
            let finalResult = idResponse.content

            // Accumulate translated results
            collectedIngredients.append(contentsOf: finalResult.indonesianIngredients.map { ArticleIngredientResult(text: $0) })
            collectedInstructions.append(contentsOf: finalResult.indonesianInstructions.map { ArticleInstructionResult(text: $0) })
        }

        // Step 4: Deduplicate
        let uniqueIngredients = deduplicate(collectedIngredients.map { $0.text })
        let uniqueInstructions = deduplicate(collectedInstructions.map { $0.text })

        // Step 5: Print results
        print("\n" + String(repeating: "=", count: 60))
        print("✅ ARTICLE EXTRACTION COMPLETE")
        print(String(repeating: "=", count: 60))
        print("📖 Recipe Name: \(foundRecipeName.isEmpty ? "(not found)" : foundRecipeName)")
        print("🥕 INGREDIENTS (\(uniqueIngredients.count)):")
        uniqueIngredients.enumerated().forEach { i, s in print("  [\(i+1)] \(s)") }
        print("📋 INSTRUCTIONS (\(uniqueInstructions.count)):")
        uniqueInstructions.enumerated().forEach { i, s in print("  [\(i+1)] \(s)") }
        print(String(repeating: "=", count: 60) + "\n")

        return (
            ingredients: uniqueIngredients,
            instructions: uniqueInstructions,
            recipeName: foundRecipeName
        )
    }

    // =========================================================================
    // MARK: - Pre-chunker (NLTokenizer + NLTagger)
    // =========================================================================

    private func prechunkArticleText(_ rawText: String) -> [String] {
        let lines = rawText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 3 && $0.count < 500 }

        var chunks: [String] = []

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        let options: NLTagger.Options = [.omitWhitespace]
        let tokenizer = NLTokenizer(unit: .sentence)
        let splitTriggers = ["and", "then", "after", "next", "dan", "kemudian", "lalu", ","]

        for line in lines {
            tokenizer.string = line
            tokenizer.enumerateTokens(in: line.startIndex..<line.endIndex) { sentenceRange, _ in
                let sentence = String(line[sentenceRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                guard !sentence.isEmpty else { return true }

                tagger.string = sentence
                var lastIndex = sentence.startIndex
                var potentialSplitPoint: String.Index? = nil

                tagger.enumerateTags(
                    in: sentence.startIndex..<sentence.endIndex,
                    unit: .word,
                    scheme: .lexicalClass,
                    options: options
                ) { tag, wordRange in
                    let word = String(sentence[wordRange])
                    let lowerWord = word.lowercased()

                    if splitTriggers.contains(lowerWord) {
                        if potentialSplitPoint == nil { potentialSplitPoint = wordRange.lowerBound }
                    } else {
                        let isVerb = (tag == .verb) || knownCookingVerbs.contains(lowerWord)

                        if isVerb, let splitIndex = potentialSplitPoint {
                            let chunk = String(sentence[lastIndex..<splitIndex])
                                .trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines))
                            if !chunk.isEmpty {
                                chunks.append(chunk.prefix(1).uppercased() + chunk.dropFirst())
                            }
                            lastIndex = wordRange.lowerBound
                            potentialSplitPoint = nil
                        } else if tag == .adverb || tag == .particle {
                            // Allow conjunctions to keep split point alive
                        } else {
                            potentialSplitPoint = nil
                        }
                    }
                    return true
                }

                // Add final remaining chunk
                let finalChunk = String(sentence[lastIndex..<sentence.endIndex])
                    .trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines))
                if !finalChunk.isEmpty {
                    chunks.append(finalChunk.prefix(1).uppercased() + finalChunk.dropFirst())
                }

                return true
            }
        }

        return chunks
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
