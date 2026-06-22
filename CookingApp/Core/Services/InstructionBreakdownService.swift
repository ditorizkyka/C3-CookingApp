import Foundation
import FoundationModels
import NaturalLanguage

@available(iOS 18.2, *)
public struct InstructionBreakdownService {
    
    func breakdownInstructions(englishInstructions: [String], ingredients: [String] = []) async throws -> [[String]] {
        var allBreakdownsEN: [[String]] = []
        
        guard case .available = SystemLanguageModel.default.availability else {
            throw NSError(domain: "RecipeNLPService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence tidak tersedia di perangkat ini."])
        }
        
        var previousContext: [String] = []
        
        for enText in englishInstructions {
            let lmSession = LanguageModelSession()
            let taggerChunks = prechunkWithTagger(input: enText)
            
            let chunksList = taggerChunks.map { "- \($0)" }.joined(separator: "\n")
            let contextString = previousContext.isEmpty ? "No previous context." : previousContext.suffix(2).joined(separator: " ")
            
            let prompt = """
            You are an expert cooking assistant. Your job is to break down the 'Current recipe text' into a list of singular, atomic cooking actions.
            
            RULES:
            1. Extract EVERY action from the text into its own step. Do NOT skip or omit any actions from the text.
            2. DO NOT invent or hallucinate new steps that are not explicitly in the text.
            3. Resolve pronouns (it, them) to the actual ingredients they refer to (e.g., "Set aside" -> "Set the anchovies aside").
            4. If a step is just the word "Remove", change it to "Remove from heat".
            5. If a step is just the word "Serve", change it to "Serve the dish".
            6. Return ONLY the broken-down steps for the 'Current recipe text'. Do not include steps from the 'Context'.
            
            Original full text (for context):
            \(enText)
            
            Context from previous steps:
            \(contextString)
            
            Current recipe text (pre-split into suggested chunks):
            \(chunksList)
            """
            
            let response = try await lmSession.respond(to: prompt, generating: RecipeActivityList.self)
            let refinedSteps = response.content.steps
            
            print("\n🤖 [AI BREAKDOWN] Original: \"\(enText)\"")
            print("   ↳ 🔪 Refined Steps:")
            for (index, step) in refinedSteps.enumerated() {
                print("       [\(index + 1)] \(step)")
            }
            print("--------------------------------------------------\n")
            
            allBreakdownsEN.append(refinedSteps)
            previousContext.append(enText)
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
            "remove", "heat", "serve", "continue", "prepare", "place", "set", "let", "uncover", "turn",
            "wash", "rinse", "dry", "toast", "flip", "garnish", "taste", "adjust", "toss", "fold",
            "crush", "mash", "scrape", "skim", "strain", "puree", "transfer", "wait", "rest", "leave",
            "decorate", "sprinkle", "drizzle", "brush", "rub", "arrange", "layer", "divide", "portion",
            "store", "refrigerate", "freeze", "thaw", "microwave", "baste", "sear", "brown", "reduce",
            "thicken", "crack", "sift", "spoon", "measure", "weigh", "discard", "coat", "dip", "soak",
            "steep", "brew", "infuse", "muddle", "plate", "flip", "simmer", "empty"
        ]
        
        let falseVerbs = [
            "flavoring", "leaves", "granulated", "spices", "seasoning", "dressing",
            "minced", "chopped", "sliced", "diced", "peeled", "grated", "mashed", "crushed",
            "lemongrass", "ginger", "galangal", "garlic", "onion", "shallot", "tomato",
            "chili", "pepper", "chicken", "beef", "pork", "fish", "salt", "sugar", "water",
            "oil", "sauce", "powder", "butter", "flour", "milk", "cheese", "cream", "egg", "eggs",
            "meat", "vegetable", "vegetables", "fruit", "fruits", "juice", "vinegar", "broth", "stock",
            "rice", "noodle", "noodles", "pasta", "bread", "crumbs", "yeast", "vanilla", "extract",
            "syrup", "honey", "soy", "paste", "puree", "pureé", "canned", "cooked", "dried", "fried",
            "roasted", "baked", "grilled", "steamed", "boiled", "poached", "smoked", "cured", "pickled",
            "fermented", "marinated", "seasoned", "spiced", "sweetened", "unsweetened", "salted", "unsalted",
            "flavor", "taste", "color", "texture", "smell", "aroma", "temperature", "heat", "cold", "warm",
            "hot", "cool", "room", "degree", "degrees", "minute", "minutes", "hour", "hours", "second",
            "seconds", "time", "day", "days", "week", "weeks", "month", "months", "year", "years", "cup",
            "cups", "tablespoon", "tablespoons", "teaspoon", "teaspoons", "ounce", "ounces", "pound",
            "pounds", "gram", "grams", "kilogram", "kilograms", "liter", "liters", "milliliter", "milliliters",
            "pinch", "dash", "drop", "drops", "handful", "bunch", "clove", "cloves", "head", "heads", "stalk",
            "stalks", "leaf", "sprig", "sprigs", "piece", "pieces", "wedge", "wedges", "cube", "cubes",
            "block", "blocks", "stick", "sticks", "package", "packages", "can", "cans", "jar", "jars",
            "bottle", "bottles", "box", "boxes", "bag", "bags", "packet", "packets", "wrap", "wrapper",
            "wrappers", "sheet", "sheets", "crust", "filling", "topping", "side", "dish", "meal", "breakfast",
            "lunch", "dinner", "snack", "dessert", "drink", "beverage", "soup", "salad", "sandwich", "burger",
            "pizza", "cake", "pie", "cookie", "cookies", "pastry", "seafood", "shellfish", "nut", "nuts",
            "seed", "seeds", "bean", "beans", "legume", "legumes", "grain", "grains", "cereal", "cereals",
            "dairy", "yogurt", "fat", "condiment", "spice", "herb", "sweetener", "ice", "wine", "beer",
            "liquor", "coffee", "tea", "soda"
        ]
        
        tokenizer.enumerateTokens(in: input.startIndex..<input.endIndex) { tokenRange, _ in
            let sentence = String(input[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            tagger.string = sentence
            var lastIndex = sentence.startIndex
            let splitTriggers = ["and", "then", "after", "next"]
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
