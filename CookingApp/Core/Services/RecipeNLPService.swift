import Foundation
import FoundationModels
import NaturalLanguage

@available(iOS 18.1, *)
@Generable
struct RecipeActivityList {
    @Guide(description: "A list of individual cooking activity steps extracted from the recipe instruction. Each step must be a single, actionable cooking command.")
    var steps: [String]
}

@available(iOS 18.2, *)
struct RecipeNLPService {
    
    func breakdownInstructions(englishInstructions: [String]) async throws -> [[String]] {
        var allBreakdownsEN: [[String]] = []
        
        guard case .available = SystemLanguageModel.default.availability else {
            throw NSError(domain: "RecipeNLPService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence tidak tersedia di perangkat ini."])
        }
        
        let lmSession = LanguageModelSession()
        
        for enText in englishInstructions {
            let taggerChunks = prechunkWithTagger(input: enText)
            
            let combinedInput = taggerChunks.joined(separator: ". ")
            let prompt = """
            You are a cooking assistant. The following are cooking activity steps that have been pre-split by a grammar parser.
            Your job is to refine them:
            - Merge any steps that are too fragmented and belong together (e.g. "Remove" and "Drain" happening at the same moment).
            - If a condition or waiting state appears (e.g. "after X is cold", "until X changes color"), convert it into an explicit waiting step: "Wait until [condition]".
            - Do NOT split ingredient lists.
            - Return the refined list of complete, actionable cooking steps.
            
            Pre-split steps: \(combinedInput)
            """
            
            let response = try await lmSession.respond(to: prompt, generating: RecipeActivityList.self)
            let refinedSteps = response.content.steps
            
            allBreakdownsEN.append(refinedSteps)
        }
        
        return allBreakdownsEN
    }
    
    private func prechunkWithTagger(input: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        let options: NLTagger.Options = [.omitWhitespace]
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = input
        
        var taggerChunks: [String] = []
        let knownVerbs = [
            "cook", "season", "preheat", "marinate", "chop", "add", "put", "pour", "shake", "peel",
            "slice", "knead", "drain", "mince", "mix", "combine", "grate", "cut", "split", "dice",
            "whip", "blend", "beat", "whisk", "dust", "stir", "cover", "melt", "grease", "spread",
            "caramelise", "caramelize", "frost", "glaze", "cool", "shape", "roll", "defrost",
            "boil", "bake", "grill", "fry", "deep-fry", "saute", "sauté", "roast", "steam",
            "simmer", "blanch", "broil", "poach", "braise", "stir-fry", "smoke", "stew",
            "remove", "heat", "serve", "continue", "prepare", "place", "set", "let", "uncover", "turn"
        ]
        let falseVerbs = [
            "flavoring", "leaves", "granulated", "spices", "seasoning", "dressing",
            "minced", "chopped", "sliced", "diced", "peeled", "grated", "mashed", "crushed",
            "lemongrass", "ginger", "galangal", "garlic", "onion", "shallot", "tomato",
            "chili", "pepper", "chicken", "beef", "pork", "fish", "salt", "sugar", "water",
            "oil", "sauce", "powder"
        ]
        
        tokenizer.enumerateTokens(in: input.startIndex..<input.endIndex) { tokenRange, _ in
            let sentence = String(input[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            tagger.string = sentence
            var lastIndex = sentence.startIndex
            let splitTriggers = ["and", "then", "after", "next", ","]
            var potentialSplitPoint: String.Index? = nil
            
            tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, wordRange in
                let word = String(sentence[wordRange])
                let lowerWord = word.lowercased()
                
                if splitTriggers.contains(lowerWord) {
                    if potentialSplitPoint == nil { potentialSplitPoint = wordRange.lowerBound }
                } else {
                    var isVerb = false
                    if let tag = tag, (tag == .verb || tag == .idiom) { isVerb = true }
                    if knownVerbs.contains(lowerWord) { isVerb = true }
                    if falseVerbs.contains(lowerWord) { isVerb = false }
                    
                    if isVerb {
                        if let splitIndex = potentialSplitPoint {
                            let chunk = String(sentence[lastIndex..<splitIndex]).trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines))
                            if !chunk.isEmpty { taggerChunks.append(chunk.prefix(1).capitalized + chunk.dropFirst()) }
                            lastIndex = wordRange.lowerBound
                            potentialSplitPoint = nil
                        }
                    } else if let tag = tag, (tag == .adverb || tag == .particle) {
                        // adverbs allowed to keep potential point alive
                    } else {
                        potentialSplitPoint = nil
                    }
                }
                return true
            }
            let finalChunk = String(sentence[lastIndex..<sentence.endIndex]).trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines))
            if !finalChunk.isEmpty { taggerChunks.append(finalChunk.prefix(1).capitalized + finalChunk.dropFirst()) }
            return true
        }
        
        return taggerChunks
    }
}
