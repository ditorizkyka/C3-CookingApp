import Foundation

// MARK: - Scraped Recipe DTO (Data Transfer Object)
struct ScrapedRecipeDTO: Codable {
    let name: String?
    let image: ScrapedImageDTO?
    let description: String?
    let datePublished: String?
    let prepTime: String?
    let cookTime: String?
    let totalTime: String?
    let recipeYield: ScrapedStringDTO?
    let recipeIngredient: [String]?
    let recipeInstructions: [ScrapedStepDTO]?
    let author: ScrapedAuthorDTO?
    let recipeCategory: ScrapedStringDTO?
    let recipeCuisine: ScrapedStringDTO?
    let keywords: ScrapedStringDTO?
    let aggregateRating: ScrapedRatingDTO?
    let nutrition: ScrapedNutritionDTO?
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
        self.image = try container.decodeIfPresent(ScrapedImageDTO.self, forKey: .image)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.datePublished = try container.decodeIfPresent(String.self, forKey: .datePublished)
        self.prepTime = try container.decodeIfPresent(String.self, forKey: .prepTime)
        self.cookTime = try container.decodeIfPresent(String.self, forKey: .cookTime)
        self.totalTime = try container.decodeIfPresent(String.self, forKey: .totalTime)
        self.recipeYield = try container.decodeIfPresent(ScrapedStringDTO.self, forKey: .recipeYield)
        self.recipeIngredient = try container.decodeIfPresent([String].self, forKey: .recipeIngredient)

        let rawInstructions = try container.decodeIfPresent([ScrapedStepDTO].self, forKey: .recipeInstructions)
        self.recipeInstructions = ScrapedStepDTO.flatten(rawInstructions)

        self.author = try container.decodeIfPresent(ScrapedAuthorDTO.self, forKey: .author)
        self.recipeCategory = try container.decodeIfPresent(ScrapedStringDTO.self, forKey: .recipeCategory)
        self.recipeCuisine = try container.decodeIfPresent(ScrapedStringDTO.self, forKey: .recipeCuisine)
        self.keywords = try container.decodeIfPresent(ScrapedStringDTO.self, forKey: .keywords)
        self.aggregateRating = try container.decodeIfPresent(ScrapedRatingDTO.self, forKey: .aggregateRating)
        self.nutrition = try container.decodeIfPresent(ScrapedNutritionDTO.self, forKey: .nutrition)
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

            if !hasQuantity && Self.isGroupHeader(parts.name) {
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

    /// Keywords that strongly indicate a group header rather than an ingredient
    private static let groupHeaderKeywords: Set<String> = [
        "bumbu", "bahan", "untuk", "saus", "kuah", "marinasi", "kaldu", "pelengkap", "isian",
        "for", "sauce", "marinade", "broth", "garnish", "topping", "dressing", "syrup", "sirup",
        "baluran", "celupan", "taburan"
    ]

    /// Determines if a string without quantity is a group header or just a single ingredient
    static func isGroupHeader(_ text: String) -> Bool {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lower.hasSuffix(":") { return true }
        
        let words = lower.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if groupHeaderKeywords.contains(word) { return true }
        }
        
        // Matches "Bahan A", "Bahan B", etc.
        if lower.hasPrefix("bahan") { return true }
        
        return false
    }

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
