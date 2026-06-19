////
////  ScrapedRecipeDTO.swift
////  CookingApp — Universal Recipe Scraper
////
////  PURPOSE:
////  This is the "bridge" between raw JSON-LD data from ANY website and
////  the app's SwiftData Recipe model. Since SwiftData @Model classes
////  cannot be directly decoded from JSON, we decode into these lightweight
////  Codable structs first, then convert to the SwiftData model via .toRecipe().
////
////  FLOW:
////  Website JSON-LD → JSONDecoder → ScrapedRecipeDTO → .toRecipe() → Recipe (@Model)
////
////  WHY NOT CookpadRawRecipe?
////  CookpadRawRecipe only handles Cookpad's specific JSON-LD format.
////  ScrapedRecipeDTO handles ALL variations: flexible image types (string, object, array),
////  flexible author (string, object, array), HowToSection/HowToStep flattening, etc.
////
//
//import Foundation
//
//// MARK: - Scraped Recipe DTO (Data Transfer Object)
//struct ScrapedRecipeDTO: Codable {
//    let name: String?
//    let image: FlexibleImage?
//    let description: String?
//    let datePublished: String?
//    let prepTime: String?
//    let cookTime: String?
//    let totalTime: String?
//    let recipeYield: FlexibleString?
//    let recipeIngredient: [String]?
//    let recipeInstructions: [ScrapedStep]?
//    let author: FlexibleAuthor?
//    let recipeCategory: FlexibleString?
//    let recipeCuisine: FlexibleString?  
//    let keywords: FlexibleString?
//    let aggregateRating: ScrapedAggregateRating?
//    let nutrition: ScrapedNutritionInfo?
//    var sourceURL: String?
//    var rawJSON: String?
//
//    enum CodingKeys: String, CodingKey {
//        case name, image, description, datePublished
//        case prepTime, cookTime, totalTime
//        case recipeYield, recipeIngredient, recipeInstructions
//        case author, recipeCategory, recipeCuisine, keywords
//        case aggregateRating, nutrition
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.name = try container.decodeIfPresent(String.self, forKey: .name)
//        self.image = try container.decodeIfPresent(FlexibleImage.self, forKey: .image)
//        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        self.datePublished = try container.decodeIfPresent(String.self, forKey: .datePublished)
//        self.prepTime = try container.decodeIfPresent(String.self, forKey: .prepTime)
//        self.cookTime = try container.decodeIfPresent(String.self, forKey: .cookTime)
//        self.totalTime = try container.decodeIfPresent(String.self, forKey: .totalTime)
//        self.recipeYield = try container.decodeIfPresent(FlexibleString.self, forKey: .recipeYield)
//        self.recipeIngredient = try container.decodeIfPresent([String].self, forKey: .recipeIngredient)
//
//        let rawInstructions = try container.decodeIfPresent([ScrapedStep].self, forKey: .recipeInstructions)
//        self.recipeInstructions = ScrapedStep.flatten(rawInstructions)
//
//        self.author = try container.decodeIfPresent(FlexibleAuthor.self, forKey: .author)
//        self.recipeCategory = try container.decodeIfPresent(FlexibleString.self, forKey: .recipeCategory)
//        self.recipeCuisine = try container.decodeIfPresent(FlexibleString.self, forKey: .recipeCuisine)
//        self.keywords = try container.decodeIfPresent(FlexibleString.self, forKey: .keywords)
//        self.aggregateRating = try container.decodeIfPresent(ScrapedAggregateRating.self, forKey: .aggregateRating)
//        self.nutrition = try container.decodeIfPresent(ScrapedNutritionInfo.self, forKey: .nutrition)
//        self.sourceURL = nil
//        self.rawJSON = nil
//    }
//
//    // MARK: - Convert DTO → SwiftData Recipe
//    func toRecipe() -> Recipe {
//        print("\n========== 🌐 UNIVERSAL SCRAPE REPORT ==========")
//        print("📍 Data Source: JSON-LD (schema.org/Recipe) — any website")
//        print("📍 Decoded into: ScrapedRecipeDTO (Codable struct)")
//        print("📍 Mapping to: Recipe (SwiftData @Model)")
//        print("=================================================")
//
//        // Convert author
//        let recipeAuthor: Author? = {
//            guard let authorName = self.author?.name, !authorName.isEmpty else { return nil }
//            return Author(
//                name: authorName,
//                username: "@\(authorName.lowercased().replacingOccurrences(of: " ", with: ""))"
//            )
//        }()
//        print("\n👤 AUTHOR: \(recipeAuthor?.name ?? "nil")")
//
//        // Convert ingredients: parse "500 gram daging sapi" into quantity + name
//        // Uses the same grouping logic as CookpadRawRecipe
//        print("\n🥕 INGREDIENTS (raw → parsed):")
//        var recipeIngredients: [Ingredient] = []
//        var currentGroup: Ingredient? = nil
//
//        for (index, rawIngredient) in (self.recipeIngredient ?? []).enumerated() {
//            let parts = Self.parseIngredientString(rawIngredient)
//            let hasQuantity = !parts.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//            print("   [\(index)] RAW: \"\(rawIngredient)\" → qty: \"\(parts.quantity)\" | name: \"\(parts.name)\"")
//
//            if !hasQuantity {
//                // Group header — opens a new group
//                let group = Ingredient(quantity: "", name: parts.name, groupIngredients: [])
//                recipeIngredients.append(group)
//                currentGroup = group
//                print("         ↳ GROUP HEADER")
//            } else if let group = currentGroup {
//                // Member of the currently open group
//                group.groupIngredients?.append(Ingredient(quantity: parts.quantity, name: parts.name))
//                print("         ↳ MEMBER of \"\(group.name)\"")
//            } else {
//                // Single top-level ingredient
//                recipeIngredients.append(Ingredient(quantity: parts.quantity, name: parts.name))
//                print("         ↳ SINGLE")
//            }
//        }
//
//        // Convert instructions: flatten steps into numbered Instruction objects
//        print("\n📝 INSTRUCTIONS:")
//        let nonSectionSteps = (self.recipeInstructions ?? []).filter { !$0.isSection }
//        let recipeInstructionsList: [Instruction] = nonSectionSteps.enumerated().map { index, step in
//            let instructionText = step.text ?? step.name ?? ""
//            let photoUrl = step.image.flatMap { URL(string: $0) }
//            print("   [\(index + 1)] text: \"\(instructionText.prefix(80))\(instructionText.count > 80 ? "..." : "")\"")
//            return Instruction(
//                sequenceNumber: index + 1,
//                text: instructionText,
//                photoUrl: photoUrl
//            )
//        }
//
//        // Parse duration from ISO 8601
//        let duration = Self.parseDurationMinutes(self.totalTime ?? self.cookTime ?? self.prepTime)
//        print("\n⏱️ DURATION: \(duration) min (raw: totalTime=\(totalTime ?? "nil"), cookTime=\(cookTime ?? "nil"), prepTime=\(prepTime ?? "nil"))")
//
//        // Parse portion from yield
//        let portion = Self.parsePortionNumber(self.recipeYield?.value)
//        print("🍽️ PORTION: \(portion) (raw: \(recipeYield?.value ?? "nil"))")
//
//        // Build cover image URL
//        let coverURL: URL? = {
//            guard let urlString = self.image?.url, !urlString.isEmpty else { return nil }
//            return URL(string: urlString)
//        }()
//
//        let recipeName = self.name ?? "Resep Tanpa Judul"
//        print("\n📌 TITLE: \"\(recipeName)\"")
//        print("\n========== ✅ UNIVERSAL SCRAPE COMPLETE ==========")
//        print("Total ingredients: \(recipeIngredients.count)")
//        print("Total instructions: \(recipeInstructionsList.count)")
//        print("=================================================\n")
//
//        return Recipe(
//            title: recipeName,
//            author: recipeAuthor,
//            coverImageUrl: coverURL,
//            portion: max(portion, 1),
//            durationInMinutes: duration > 0 ? duration : 30,
//            ingredients: recipeIngredients,
//            instructions: recipeInstructionsList
//        )
//    }
//
//    // MARK: - Parsing Helpers
//
//    /// Unicode fraction characters mapped to their decimal string equivalents
//    private static let unicodeFractions: [Character: String] = [
//        "½": "1/2", "⅓": "1/3", "⅔": "2/3",
//        "¼": "1/4", "¾": "3/4",
//        "⅕": "1/5", "⅖": "2/5", "⅗": "3/5", "⅘": "4/5",
//        "⅙": "1/6", "⅚": "5/6",
//        "⅛": "1/8", "⅜": "3/8", "⅝": "5/8", "⅞": "7/8"
//    ]
//
//    /// Known measurement units (Indonesian + English)
//    private static let knownUnits: Set<String> = [
//        // Indonesian
//        "sdm", "sdt", "ml", "gram", "g", "kg", "liter", "l",
//        "buah", "siung", "butir", "lembar", "batang", "bungkus",
//        "sendok", "cc", "potong", "iris", "helai", "tangkai",
//        "genggam", "sejumput", "sachet", "biji", "ekor", "ikat",
//        "ruas", "kotak", "kaleng", "gelas", "mangkok", "cangkir",
//        "ons", "secukupnya",
//        // English
//        "cup", "cups", "tbsp", "tsp", "oz", "lb", "lbs",
//        "teaspoon", "teaspoons", "tablespoon", "tablespoons",
//        "piece", "pieces", "clove", "cloves", "slice", "slices",
//        "pinch", "dash", "bunch", "can", "package", "packet",
//        "ounce", "ounces", "pound", "pounds", "quart", "pint",
//        "fillet", "fillets", "head", "stalk", "stalks", "sprig", "sprigs"
//    ]
//
//    /// Parses "500 gram daging sapi" → (quantity: "500 gram", name: "daging sapi")
//    static func parseIngredientString(_ raw: String) -> (quantity: String, name: String) {
//        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else {
//            return (quantity: "", name: trimmed)
//        }
//
//        // Replace unicode fractions with ASCII equivalents
//        var normalized = trimmed
//        for (unicodeFrac, replacement) in unicodeFractions {
//            normalized = normalized.replacingOccurrences(of: String(unicodeFrac), with: replacement)
//        }
//
//        let words = normalized.components(separatedBy: " ").filter { !$0.isEmpty }
//        guard !words.isEmpty else {
//            return (quantity: "", name: trimmed)
//        }
//
//        // Check standalone quantity words
//        let standaloneQuantityWords: Set<String> = ["secukupnya", "sejumput", "sesuai", "sedikit"]
//        if standaloneQuantityWords.contains(words[0].lowercased()) {
//            let qty = words[0]
//            let name = words.dropFirst().joined(separator: " ")
//            return (quantity: qty, name: name.isEmpty ? qty : name)
//        }
//
//        // Try regex for number + optional unit + name
//        let pattern = #"^([\d¼½¾⅓⅔⅛⅜⅝⅞/.,\s-–]+)\s*(gram|g|kg|ml|liter|l|cup|cups|tbsp|tsp|sdm|sdt|buah|butir|siung|lembar|batang|ikat|bungkus|sachet|ons|mangkok|sendok|potong|iris|helai|lonjor|oz|ounce|ounces|lb|lbs|pound|pounds|piece|pieces|clove|cloves|slice|slices|pinch|dash|bunch|can|package|packet|tablespoon|tablespoons|teaspoon|teaspoons)?\s*(.+)$"#
//        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
//            let nsString = normalized as NSString
//            let results = regex.matches(in: normalized, range: NSRange(location: 0, length: nsString.length))
//            if let result = results.first, result.numberOfRanges >= 4 {
//                let numberPart = nsString.substring(with: result.range(at: 1)).trimmingCharacters(in: .whitespaces)
//                let unitPart = result.range(at: 2).location != NSNotFound
//                    ? nsString.substring(with: result.range(at: 2)).trimmingCharacters(in: .whitespaces)
//                    : ""
//                let namePart = nsString.substring(with: result.range(at: 3)).trimmingCharacters(in: .whitespaces)
//
//                let quantity = unitPart.isEmpty ? numberPart : "\(numberPart) \(unitPart)"
//                return (quantity: quantity, name: namePart)
//            }
//        }
//
//        // Fallback: if no number found, entire string is the name
//        return (quantity: "", name: trimmed)
//    }
//
//    /// Parses ISO 8601 duration "PT1H30M" → 90 (minutes)
//    static func parseDurationMinutes(_ iso: String?) -> Int {
//        guard let iso = iso else { return 0 }
//
//        var remaining = iso.uppercased()
//        guard remaining.hasPrefix("P") else { return 0 }
//        remaining.removeFirst() // Remove "P"
//
//        var totalMinutes = 0
//
//        // Parse days
//        if let dRange = remaining.range(of: "D") {
//            let days = Int(remaining[remaining.startIndex..<dRange.lowerBound]) ?? 0
//            totalMinutes += days * 24 * 60
//            remaining = String(remaining[dRange.upperBound...])
//        }
//
//        // Remove "T"
//        if remaining.hasPrefix("T") { remaining.removeFirst() }
//
//        // Parse hours
//        if let hRange = remaining.range(of: "H") {
//            let hours = Int(remaining[remaining.startIndex..<hRange.lowerBound]) ?? 0
//            totalMinutes += hours * 60
//            remaining = String(remaining[hRange.upperBound...])
//        }
//
//        // Parse minutes
//        if let mRange = remaining.range(of: "M") {
//            let minutes = Int(remaining[remaining.startIndex..<mRange.lowerBound]) ?? 0
//            totalMinutes += minutes
//        }
//
//        return totalMinutes
//    }
//
//    /// Parses "4 servings" or "4" → 4
//    static func parsePortionNumber(_ yield: String?) -> Int {
//        guard let yield = yield else { return 0 }
//        let digits = yield.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        return Int(digits) ?? 0
//    }
//}
//
//// MARK: - Flexible Image
///// Handles JSON-LD image field which can be: a string URL, an object with "url" key, an array of strings, or an array of objects
//struct FlexibleImage: Codable {
//    let url: String
//    let allURLs: [String]
//
//    init(url: String) {
//        self.url = url
//        self.allURLs = [url]
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//
//        if let urlString = try? container.decode(String.self) {
//            self.url = urlString
//            self.allURLs = [urlString]
//            return
//        }
//        if let obj = try? container.decode(ImageObject.self) {
//            self.url = obj.url ?? ""
//            self.allURLs = [obj.url ?? ""]
//            return
//        }
//        if let arr = try? container.decode([String].self) {
//            self.url = arr.first ?? ""
//            self.allURLs = arr
//            return
//        }
//        if let arr = try? container.decode([ImageObject].self) {
//            let urls = arr.compactMap { $0.url }
//            self.url = urls.first ?? ""
//            self.allURLs = urls
//            return
//        }
//        self.url = ""
//        self.allURLs = []
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(url)
//    }
//
//    private struct ImageObject: Codable {
//        let url: String?
//    }
//}
//
//// MARK: - Flexible String
///// Handles JSON-LD fields that can be: a string, an array of strings, or a number
//struct FlexibleString: Codable {
//    let value: String
//    let allValues: [String]
//
//    init(value: String) {
//        self.value = value
//        self.allValues = [value]
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let str = try? container.decode(String.self) {
//            self.value = str
//            self.allValues = [str]
//            return
//        }
//        if let arr = try? container.decode([String].self) {
//            self.value = arr.joined(separator: ", ")
//            self.allValues = arr
//            return
//        }
//        if let intVal = try? container.decode(Int.self) {
//            self.value = "\(intVal)"
//            self.allValues = ["\(intVal)"]
//            return
//        }
//        self.value = ""
//        self.allValues = []
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(value)
//    }
//}
//
//// MARK: - Flexible Author
///// Handles JSON-LD author field: a string, an object with "name", or an array of author objects
//struct FlexibleAuthor: Codable {
//    let name: String
//
//    init(name: String) {
//        self.name = name
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let str = try? container.decode(String.self) {
//            self.name = str
//            return
//        }
//        if let obj = try? container.decode(AuthorObject.self) {
//            self.name = obj.name ?? "Unknown"
//            return
//        }
//        if let arr = try? container.decode([AuthorObject].self), let first = arr.first {
//            self.name = first.name ?? "Unknown"
//            return
//        }
//        self.name = "Unknown"
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(name)
//    }
//
//    private struct AuthorObject: Codable {
//        let name: String?
//    }
//}
//
//// MARK: - Scraped Step (handles HowToStep, HowToSection, plain strings)
///// Handles the many formats websites use for recipeInstructions:
///// - Plain string: "Boil the water"
///// - HowToStep object: { "@type": "HowToStep", "text": "Boil the water" }
///// - HowToSection with nested HowToSteps
//struct ScrapedStep: Codable, Identifiable {
//    let id: UUID
//    let text: String?
//    let name: String?
//    let image: String?
//    let isSection: Bool
//    var itemListElement: [ScrapedStep]? = nil
//
//    enum CodingKeys: String, CodingKey {
//        case text, name, image
//        case type = "@type"
//        case itemListElement
//    }
//
//    init(text: String?, name: String? = nil, image: String? = nil, isSection: Bool = false) {
//        self.id = UUID()
//        self.text = text
//        self.name = name
//        self.image = image
//        self.isSection = isSection
//    }
//
//    init(from decoder: Decoder) throws {
//        self.id = UUID()
//
//        // Handle plain string format: "Boil the water"
//        if let container = try? decoder.singleValueContainer(),
//           let str = try? container.decode(String.self) {
//            self.text = str
//            self.name = nil
//            self.image = nil
//            self.isSection = false
//            return
//        }
//
//        // Handle object format: { "@type": "HowToStep", "text": "..." }
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let type = try container.decodeIfPresent(String.self, forKey: .type)
//        self.name = try container.decodeIfPresent(String.self, forKey: .name)
//        self.text = try container.decodeIfPresent(String.self, forKey: .text)
//
//        if let imgStr = try? container.decode(String.self, forKey: .image) {
//            self.image = imgStr
//        } else if let imgObj = try? container.decode(FlexibleImage.self, forKey: .image) {
//            self.image = imgObj.url
//        } else {
//            self.image = nil
//        }
//
//        self.itemListElement = try container.decodeIfPresent([ScrapedStep].self, forKey: .itemListElement)
//        self.isSection = (type == "HowToSection" || (self.itemListElement != nil && self.name != nil))
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(text, forKey: .text)
//        try container.encodeIfPresent(name, forKey: .name)
//        try container.encodeIfPresent(image, forKey: .image)
//        try container.encodeIfPresent(itemListElement, forKey: .itemListElement)
//    }
//
//    // MARK: - Flatten Helper
//    /// Recursively flattens HowToSection → HowToStep hierarchy into a flat array
//    static func flatten(_ steps: [ScrapedStep]?) -> [ScrapedStep]? {
//        guard let steps = steps else { return nil }
//        var result: [ScrapedStep] = []
//
//        for step in steps {
//            if step.text != nil || step.name != nil {
//                result.append(step)
//            }
//            if let nestedItems = step.itemListElement {
//                if let flattenedNested = flatten(nestedItems) {
//                    result.append(contentsOf: flattenedNested)
//                }
//            }
//        }
//
//        return result.isEmpty ? nil : result
//    }
//}
//
//// MARK: - Aggregate Rating
//struct ScrapedAggregateRating: Codable {
//    let ratingValue: FlexibleDouble?
//    let ratingCount: FlexibleDouble?
//    let reviewCount: FlexibleDouble?
//    let bestRating: FlexibleDouble?
//}
//
//// MARK: - Flexible Double
///// Handles JSON values that can be either a number or a string representation of a number
//struct FlexibleDouble: Codable {
//    let value: Double
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let dbl = try? container.decode(Double.self) {
//            self.value = dbl
//        } else if let str = try? container.decode(String.self), let dbl = Double(str) {
//            self.value = dbl
//        } else {
//            self.value = 0
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(value)
//    }
//}
//
//// MARK: - Nutrition Info
//struct ScrapedNutritionInfo: Codable {
//    let calories: String?
//    let fatContent: String?
//    let carbohydrateContent: String?
//    let proteinContent: String?
//    let fiberContent: String?
//    let sugarContent: String?
//    let sodiumContent: String?
//    let cholesterolContent: String?
//    let saturatedFatContent: String?
//    let unsaturatedFatContent: String?
//    let transFatContent: String?
//    let servingSize: String?
//}
