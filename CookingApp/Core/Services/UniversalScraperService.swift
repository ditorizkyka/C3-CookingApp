//
//  ScrapedRecipeDTO.swift
//  CookingApp — Universal Recipe Scraper
//
//  PURPOSE:
//  This is the "bridge" between raw JSON-LD data from ANY website and
//  the app's SwiftData Recipe model. Since SwiftData @Model classes
//  cannot be directly decoded from JSON, we decode into these lightweight
//  Codable structs first, then convert to the SwiftData model via .toRecipe().
//
//  FLOW:
//  Website JSON-LD → JSONDecoder → ScrapedRecipeDTO → .toRecipe() → Recipe (@Model)
//
//  WHY NOT CookpadRawRecipe?
//  CookpadRawRecipe only handles Cookpad's specific JSON-LD format.
//  ScrapedRecipeDTO handles ALL variations: flexible image types (string, object, array),
//  flexible author (string, object, array), HowToSection/HowToStep flattening, etc.
//

import Foundation

// MARK: - Scraped Recipe DTO (Data Transfer Object)
struct ScrapedRecipeDTO: Codable {
    let name: String?
    let image: FlexibleImage?
    let description: String?
    let datePublished: String?
    let prepTime: String?
    let cookTime: String?
    let totalTime: String?
    let recipeYield: FlexibleString?
    let recipeIngredient: [String]?
    let recipeInstructions: [ScrapedStep]?
    let author: FlexibleAuthor?
    let recipeCategory: FlexibleString?
    let recipeCuisine: FlexibleString?
    let keywords: FlexibleString?
    let aggregateRating: ScrapedAggregateRating?
    let nutrition: ScrapedNutritionInfo?
    var sourceURL: String?
    var rawJSON: String?

    enum CodingKeys: String, CodingKey {
        case name, image, description, datePublished
        case prepTime, cookTime, totalTime
        case recipeYield, recipeIngredient, recipeInstructions
        case author, recipeCategory, recipeCuisine, keywords
        case aggregateRating, nutrition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(FlexibleImage.self, forKey: .image)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.datePublished = try container.decodeIfPresent(String.self, forKey: .datePublished)
        self.prepTime = try container.decodeIfPresent(String.self, forKey: .prepTime)
        self.cookTime = try container.decodeIfPresent(String.self, forKey: .cookTime)
        self.totalTime = try container.decodeIfPresent(String.self, forKey: .totalTime)
        self.recipeYield = try container.decodeIfPresent(FlexibleString.self, forKey: .recipeYield)
        self.recipeIngredient = try container.decodeIfPresent([String].self, forKey: .recipeIngredient)

        let rawInstructions = try container.decodeIfPresent([ScrapedStep].self, forKey: .recipeInstructions)
        self.recipeInstructions = ScrapedStep.flatten(rawInstructions)

        self.author = try container.decodeIfPresent(FlexibleAuthor.self, forKey: .author)
        self.recipeCategory = try container.decodeIfPresent(FlexibleString.self, forKey: .recipeCategory)
        self.recipeCuisine = try container.decodeIfPresent(FlexibleString.self, forKey: .recipeCuisine)
        self.keywords = try container.decodeIfPresent(FlexibleString.self, forKey: .keywords)
        self.aggregateRating = try container.decodeIfPresent(ScrapedAggregateRating.self, forKey: .aggregateRating)
        self.nutrition = try container.decodeIfPresent(ScrapedNutritionInfo.self, forKey: .nutrition)
        self.sourceURL = nil
        self.rawJSON = nil
    }

    // MARK: - Convert DTO → SwiftData Recipe
    func toRecipe() -> Recipe {
        print("\n========== 🌐 UNIVERSAL SCRAPE REPORT ==========")
        print("📍 Data Source: JSON-LD (schema.org/Recipe) — any website")
        print("📍 Decoded into: ScrapedRecipeDTO (Codable struct)")
        print("📍 Mapping to: Recipe (SwiftData @Model)")
        print("=================================================")

        // Convert author
        let recipeAuthor: Author? = {
            guard let authorName = self.author?.name, !authorName.isEmpty else { return nil }
            return Author(
                name: authorName,
                username: "@\(authorName.lowercased().replacingOccurrences(of: " ", with: ""))"
            )
        }()
        print("\n👤 AUTHOR: \(recipeAuthor?.name ?? "nil")")

        // Convert ingredients: parse "500 gram daging sapi" into quantity + name
        // Uses the same grouping logic as CookpadRawRecipe
        print("\n🥕 INGREDIENTS (raw → parsed):")
        var recipeIngredients: [Ingredient] = []
        var currentGroup: Ingredient? = nil

        for (index, rawIngredient) in (self.recipeIngredient ?? []).enumerated() {
            let parts = Self.parseIngredientString(rawIngredient)
            let hasQuantity = !parts.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            print("   [\(index)] RAW: \"\(rawIngredient)\" → qty: \"\(parts.quantity)\" | name: \"\(parts.name)\"")

            if !hasQuantity {
                // Group header — opens a new group
                let group = Ingredient(quantity: "", name: parts.name, groupIngredients: [])
                recipeIngredients.append(group)
                currentGroup = group
                print("         ↳ GROUP HEADER")
            } else if let group = currentGroup {
                // Member of the currently open group
                group.groupIngredients?.append(Ingredient(quantity: parts.quantity, name: parts.name))
                print("         ↳ MEMBER of \"\(group.name)\"")
            } else {
                // Single top-level ingredient
                recipeIngredients.append(Ingredient(quantity: parts.quantity, name: parts.name))
                print("         ↳ SINGLE")
            }
        }

        // Convert instructions: flatten steps into numbered Instruction objects
        print("\n📝 INSTRUCTIONS:")
        let nonSectionSteps = (self.recipeInstructions ?? []).filter { !$0.isSection }
        let recipeInstructionsList: [Instruction] = nonSectionSteps.enumerated().map { index, step in
            let instructionText = step.text ?? step.name ?? ""
            let photoUrl = step.image.flatMap { URL(string: $0) }
            print("   [\(index + 1)] text: \"\(instructionText.prefix(80))\(instructionText.count > 80 ? "..." : "")\"")
            return Instruction(
                sequenceNumber: index + 1,
                text: instructionText,
                photoUrl: photoUrl
            )
        }

        // Parse duration from ISO 8601
        let duration = Self.parseDurationMinutes(self.totalTime ?? self.cookTime ?? self.prepTime)
        print("\n⏱️ DURATION: \(duration) min (raw: totalTime=\(totalTime ?? "nil"), cookTime=\(cookTime ?? "nil"), prepTime=\(prepTime ?? "nil"))")

        // Parse portion from yield
        let portion = Self.parsePortionNumber(self.recipeYield?.value)
        print("🍽️ PORTION: \(portion) (raw: \(recipeYield?.value ?? "nil"))")

        // Build cover image URL
        let coverURL: URL? = {
            guard let urlString = self.image?.url, !urlString.isEmpty else { return nil }
            return URL(string: urlString)
        }()

        let recipeName = self.name ?? "Resep Tanpa Judul"
        print("\n📌 TITLE: \"\(recipeName)\"")
        print("\n========== ✅ UNIVERSAL SCRAPE COMPLETE ==========")
        print("Total ingredients: \(recipeIngredients.count)")
        print("Total instructions: \(recipeInstructionsList.count)")
        print("=================================================\n")

        var finalDuration = duration > 0 ? duration : 30
        if finalDuration > 120 {
            finalDuration = 121
        }

        return Recipe(
            title: recipeName,
            author: recipeAuthor,
            coverImageUrl: coverURL,
            portion: 0,
            durationInMinutes: finalDuration,
            ingredients: recipeIngredients,
            instructions: recipeInstructionsList
        )
    }

    // MARK: - Parsing Helpers

    /// Unicode fraction characters mapped to their decimal string equivalents
    private static let unicodeFractions: [Character: String] = [
        "½": "1/2", "⅓": "1/3", "⅔": "2/3",
        "¼": "1/4", "¾": "3/4",
        "⅕": "1/5", "⅖": "2/5", "⅗": "3/5", "⅘": "4/5",
        "⅙": "1/6", "⅚": "5/6",
        "⅛": "1/8", "⅜": "3/8", "⅝": "5/8", "⅞": "7/8"
    ]

    /// Known measurement units (Indonesian + English)
    private static let knownUnits: Set<String> = [
        // Indonesian
        "sdm", "sdt", "ml", "gram", "g", "kg", "liter", "l",
        "buah", "siung", "butir", "lembar", "batang", "bungkus",
        "sendok", "cc", "potong", "iris", "helai", "tangkai",
        "genggam", "sejumput", "sachet", "biji", "ekor", "ikat",
        "ruas", "kotak", "kaleng", "gelas", "mangkok", "cangkir",
        "ons", "secukupnya",
        // English
        "cup", "cups", "tbsp", "tsp", "oz", "lb", "lbs",
        "teaspoon", "teaspoons", "tablespoon", "tablespoons",
        "piece", "pieces", "clove", "cloves", "slice", "slices",
        "pinch", "dash", "bunch", "can", "package", "packet",
        "ounce", "ounces", "pound", "pounds", "quart", "pint",
        "fillet", "fillets", "head", "stalk", "stalks", "sprig", "sprigs"
    ]

    /// Parses "500 gram daging sapi" → (quantity: "500 gram", name: "daging sapi")
    static func parseIngredientString(_ raw: String) -> (quantity: String, name: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (quantity: "", name: trimmed)
        }

        // Replace unicode fractions with ASCII equivalents
        var normalized = trimmed
        for (unicodeFrac, replacement) in unicodeFractions {
            normalized = normalized.replacingOccurrences(of: String(unicodeFrac), with: replacement)
        }

        let words = normalized.components(separatedBy: " ").filter { !$0.isEmpty }
        guard !words.isEmpty else {
            return (quantity: "", name: trimmed)
        }

        // Check standalone quantity words
        let standaloneQuantityWords: Set<String> = ["secukupnya", "sejumput", "sesuai", "sedikit"]
        if standaloneQuantityWords.contains(words[0].lowercased()) {
            let qty = words[0]
            let name = words.dropFirst().joined(separator: " ")
            return (quantity: qty, name: name.isEmpty ? qty : name)
        }

        // Try regex for number + optional unit + name
        let pattern = #"^([\d¼½¾⅓⅔⅛⅜⅝⅞/.,\s-–]+)\s*(gram|g|kg|ml|liter|l|cup|cups|tbsp|tsp|sdm|sdt|buah|butir|siung|lembar|batang|ikat|bungkus|sachet|ons|mangkok|sendok|potong|iris|helai|lonjor|oz|ounce|ounces|lb|lbs|pound|pounds|piece|pieces|clove|cloves|slice|slices|pinch|dash|bunch|can|package|packet|tablespoon|tablespoons|teaspoon|teaspoons)?\s*(.+)$"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let nsString = normalized as NSString
            let results = regex.matches(in: normalized, range: NSRange(location: 0, length: nsString.length))
            if let result = results.first, result.numberOfRanges >= 4 {
                let numberPart = nsString.substring(with: result.range(at: 1)).trimmingCharacters(in: .whitespaces)
                let unitPart = result.range(at: 2).location != NSNotFound
                    ? nsString.substring(with: result.range(at: 2)).trimmingCharacters(in: .whitespaces)
                    : ""
                let namePart = nsString.substring(with: result.range(at: 3)).trimmingCharacters(in: .whitespaces)

                let quantity = unitPart.isEmpty ? numberPart : "\(numberPart) \(unitPart)"
                return (quantity: quantity, name: namePart)
            }
        }

        // Fallback: if no number found, entire string is the name
        return (quantity: "", name: trimmed)
    }

    /// Parses ISO 8601 duration "PT1H30M" → 90 (minutes)
    static func parseDurationMinutes(_ iso: String?) -> Int {
        guard let iso = iso else { return 0 }

        var remaining = iso.uppercased()
        guard remaining.hasPrefix("P") else { return 0 }
        remaining.removeFirst() // Remove "P"

        var totalMinutes = 0

        // Parse days
        if let dRange = remaining.range(of: "D") {
            let days = Int(remaining[remaining.startIndex..<dRange.lowerBound]) ?? 0
            totalMinutes += days * 24 * 60
            remaining = String(remaining[dRange.upperBound...])
        }

        // Remove "T"
        if remaining.hasPrefix("T") { remaining.removeFirst() }

        // Parse hours
        if let hRange = remaining.range(of: "H") {
            let hours = Int(remaining[remaining.startIndex..<hRange.lowerBound]) ?? 0
            totalMinutes += hours * 60
            remaining = String(remaining[hRange.upperBound...])
        }

        // Parse minutes
        if let mRange = remaining.range(of: "M") {
            let minutes = Int(remaining[remaining.startIndex..<mRange.lowerBound]) ?? 0
            totalMinutes += minutes
        }

        return totalMinutes
    }

    /// Parses "4 servings" or "4" → 4
    static func parsePortionNumber(_ yield: String?) -> Int {
        guard let yield = yield else { return 0 }
        let digits = yield.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits) ?? 0
    }
}

// MARK: - Flexible Image
/// Handles JSON-LD image field which can be: a string URL, an object with "url" key, an array of strings, or an array of objects
struct FlexibleImage: Codable {
    let url: String
    let allURLs: [String]

    init(url: String) {
        self.url = url
        self.allURLs = [url]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let urlString = try? container.decode(String.self) {
            self.url = urlString
            self.allURLs = [urlString]
            return
        }
        if let obj = try? container.decode(ImageObject.self) {
            self.url = obj.url ?? ""
            self.allURLs = [obj.url ?? ""]
            return
        }
        if let arr = try? container.decode([String].self) {
            self.url = arr.first ?? ""
            self.allURLs = arr
            return
        }
        if let arr = try? container.decode([ImageObject].self) {
            let urls = arr.compactMap { $0.url }
            self.url = urls.first ?? ""
            self.allURLs = urls
            return
        }
        self.url = ""
        self.allURLs = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }

    private struct ImageObject: Codable {
        let url: String?
    }
}

// MARK: - Flexible String
/// Handles JSON-LD fields that can be: a string, an array of strings, or a number
struct FlexibleString: Codable {
    let value: String
    let allValues: [String]

    init(value: String) {
        self.value = value
        self.allValues = [value]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self.value = str
            self.allValues = [str]
            return
        }
        if let arr = try? container.decode([String].self) {
            self.value = arr.joined(separator: ", ")
            self.allValues = arr
            return
        }
        if let intVal = try? container.decode(Int.self) {
            self.value = "\(intVal)"
            self.allValues = ["\(intVal)"]
            return
        }
        self.value = ""
        self.allValues = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Flexible Author
/// Handles JSON-LD author field: a string, an object with "name", or an array of author objects
struct FlexibleAuthor: Codable {
    let name: String

    init(name: String) {
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self.name = str
            return
        }
        if let obj = try? container.decode(AuthorObject.self) {
            self.name = obj.name ?? "Unknown"
            return
        }
        if let arr = try? container.decode([AuthorObject].self), let first = arr.first {
            self.name = first.name ?? "Unknown"
            return
        }
        self.name = "Unknown"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }

    private struct AuthorObject: Codable {
        let name: String?
    }
}

// MARK: - Scraped Step (handles HowToStep, HowToSection, plain strings)
/// Handles the many formats websites use for recipeInstructions:
/// - Plain string: "Boil the water"
/// - HowToStep object: { "@type": "HowToStep", "text": "Boil the water" }
/// - HowToSection with nested HowToSteps
struct ScrapedStep: Codable, Identifiable {
    let id: UUID
    let text: String?
    let name: String?
    let image: String?
    let isSection: Bool
    var itemListElement: [ScrapedStep]? = nil

    enum CodingKeys: String, CodingKey {
        case text, name, image
        case type = "@type"
        case itemListElement
    }

    init(text: String?, name: String? = nil, image: String? = nil, isSection: Bool = false) {
        self.id = UUID()
        self.text = text
        self.name = name
        self.image = image
        self.isSection = isSection
    }

    init(from decoder: Decoder) throws {
        self.id = UUID()

        // Handle plain string format: "Boil the water"
        if let container = try? decoder.singleValueContainer(),
           let str = try? container.decode(String.self) {
            self.text = str
            self.name = nil
            self.image = nil
            self.isSection = false
            return
        }

        // Handle object format: { "@type": "HowToStep", "text": "..." }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)

        if let imgStr = try? container.decode(String.self, forKey: .image) {
            self.image = imgStr
        } else if let imgObj = try? container.decode(FlexibleImage.self, forKey: .image) {
            self.image = imgObj.url
        } else {
            self.image = nil
        }

        self.itemListElement = try container.decodeIfPresent([ScrapedStep].self, forKey: .itemListElement)
        self.isSection = (type == "HowToSection" || (self.itemListElement != nil && self.name != nil))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(itemListElement, forKey: .itemListElement)
    }

    // MARK: - Flatten Helper
    /// Recursively flattens HowToSection → HowToStep hierarchy into a flat array
    static func flatten(_ steps: [ScrapedStep]?) -> [ScrapedStep]? {
        guard let steps = steps else { return nil }
        var result: [ScrapedStep] = []

        for step in steps {
            if step.text != nil || step.name != nil {
                result.append(step)
            }
            if let nestedItems = step.itemListElement {
                if let flattenedNested = flatten(nestedItems) {
                    result.append(contentsOf: flattenedNested)
                }
            }
        }

        return result.isEmpty ? nil : result
    }
}

// MARK: - Aggregate Rating
struct ScrapedAggregateRating: Codable {
    let ratingValue: FlexibleDouble?
    let ratingCount: FlexibleDouble?
    let reviewCount: FlexibleDouble?
    let bestRating: FlexibleDouble?
}

// MARK: - Flexible Double
/// Handles JSON values that can be either a number or a string representation of a number
struct FlexibleDouble: Codable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dbl = try? container.decode(Double.self) {
            self.value = dbl
        } else if let str = try? container.decode(String.self), let dbl = Double(str) {
            self.value = dbl
        } else {
            self.value = 0
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Nutrition Info
struct ScrapedNutritionInfo: Codable {
    let calories: String?
    let fatContent: String?
    let carbohydrateContent: String?
    let proteinContent: String?
    let fiberContent: String?
    let sugarContent: String?
    let sodiumContent: String?
    let cholesterolContent: String?
    let saturatedFatContent: String?
    let unsaturatedFatContent: String?
    let transFatContent: String?
    let servingSize: String?
}
//
//  ArticleRecipeExtractor.swift
//  CookingApp — Universal Recipe Scraper
//
//  PURPOSE:
//  This service handles the "article" use-case — websites like Sasa.co.id and
//  Halodoc.com that publish recipes inside a blog/article format and do NOT
//  provide a proper `@type: "Recipe"` JSON-LD tag.
//
//  HOW IT WORKS:
//  1. We receive the raw page text scraped from the article website.
//  2. We use NLTokenizer (.sentence) + NLTagger (.lexicalClass) to pre-chunk the
//     text into smaller, semantically meaningful segments.
//  3. We feed each chunk into Apple's on-device Foundation Model
//     (SystemLanguageModel) using a `LanguageModelSession`.
//  4. We inject a carefully-written PROMPT that tells the Foundation Model
//     exactly what to look for:
//       - Lines that look like INGREDIENTS (quantity + unit + food item)
//       - Lines that look like COOKING STEPS/INSTRUCTIONS (action verbs)
//       - Lines that are just NORMAL ARTICLE TEXT (story, health advice, etc.)
//  5. The model returns a strongly-typed @Generable struct, so there is no
//     fragile JSON parsing — it's compile-time safe.
//
//  APPLE FRAMEWORKS USED:
//  - FoundationModels   → SystemLanguageModel, LanguageModelSession, @Generable
//  - NaturalLanguage    → NLTokenizer (.sentence), NLTagger (.lexicalClass)
//  - Foundation         → Swift concurrency (async/await)
//

import Foundation
import NaturalLanguage

#if canImport(FoundationModels)
import FoundationModels

// =============================================================================
// MARK: - @Generable Output Types
// =============================================================================

/// Represents one extracted ingredient line from an article
@available(iOS 26.0, *)
@Generable
struct ArticleIngredient {
    @Guide(description: "A single ingredient line from the recipe article. Must include quantity and food item if present. Example: '500 gram daging sapi' or '2 siung bawang putih'.")
    var text: String
}

/// Represents one extracted instruction step from an article
@available(iOS 26.0, *)
@Generable
struct ArticleInstructionStep {
    @Guide(description: "A single cooking instruction step from the recipe article. Must be one complete, actionable command. Example: 'Tumis bawang putih dan bawang merah hingga harum.' or 'Preheat oven to 180 degrees Celsius.'")
    var text: String
}

/// The full structured extraction result returned by the Foundation Model
@available(iOS 26.0, *)
@Generable
struct ArticleRecipeExtractionResult {
    @Guide(description: "The name/title of the recipe extracted from the article text. If not found, return an empty string.")
    var recipeName: String

    @Guide(description: "All ingredient lines found in the article. Each item must be a distinct ingredient with its quantity and unit. Do NOT include cooking steps, blog stories, health tips, or navigation text as ingredients.")
    var ingredients: [ArticleIngredient]

    @Guide(description: "All cooking instruction steps found in the article, in the correct order. Each item must be one complete cooking action. Do NOT include ingredient lists, blog stories, health tips, or navigation text as instructions.")
    var instructions: [ArticleInstructionStep]
}

// =============================================================================
// MARK: - Pipeline Translation Types
// =============================================================================

/// Used for translating the raw batch ID -> EN
@available(iOS 26.0, *)
@Generable
struct TranslationToEnglishResult {
    @Guide(description: "The English translation of the provided text. If the text is already in English, return it exactly as is.")
    var englishText: String
}

/// Used for translating the extracted recipe EN -> ID
@available(iOS 26.0, *)
@Generable
struct TranslatedRecipeResult {
    @Guide(description: "The translated list of ingredients in Indonesian. Preserve exact measurements.")
    var indonesianIngredients: [String]

    @Guide(description: "The translated list of cooking instructions in Indonesian.")
    var indonesianInstructions: [String]
}

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
        var collectedIngredients: [ArticleIngredient] = []
        var collectedInstructions: [ArticleInstructionStep] = []
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
            collectedIngredients.append(contentsOf: finalResult.indonesianIngredients.map { ArticleIngredient(text: $0) })
            collectedInstructions.append(contentsOf: finalResult.indonesianInstructions.map { ArticleInstructionStep(text: $0) })
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

// =============================================================================
// MARK: - Error Types
// =============================================================================

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
