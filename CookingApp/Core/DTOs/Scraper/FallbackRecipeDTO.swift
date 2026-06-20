//
//  CookpadRawRecipe.swift
//  CookingApp
//
//  Intermediate Codable struct for decoding Cookpad's LD+JSON (schema.org/Recipe).
//  SwiftData @Model classes can't be decoded directly from JSON, so we decode into
//  this struct first, then map to the app's Recipe model.
//

import Foundation

// MARK: - Raw Cookpad Recipe (Codable)
struct FallbackRecipeDTO: Codable {
    let name: String?
    let author: FallbackAuthor?
    let image: FallbackImage?
    let recipeYield: FallbackYield?
    let totalTime: String?
    let cookTime: String?
    let prepTime: String?
    let recipeIngredient: [String]?
    let recipeInstructions: [FallbackInstruction]?
    
    enum CodingKeys: String, CodingKey {
        case name, author, image
        case recipeYield, totalTime, cookTime, prepTime
        case recipeIngredient, recipeInstructions
    }
}


// MARK: - Mapping to App's SwiftData Model
extension FallbackRecipeDTO {
    
    /// Convert scraped Cookpad LD+JSON data into the app's SwiftData `Recipe` model.
    ///
    /// DATA FLOW:
    /// 1. LD+JSON `<script type="application/ld+json">` tag is found in the HTML
    /// 2. JavaScript extracts the JSON string from the page
    /// 3. JSON is decoded into `FallbackRecipeDTO` (this struct)
    /// 4. This function maps `FallbackRecipeDTO` → `Recipe` (SwiftData model)
    func toRecipe() -> Recipe {
        print("\n========== 🍳 SCRAPE DATA REPORT ==========")
        print("📍 Data Source: LD+JSON (schema.org/Recipe) from HTML <script> tag")
        print("📍 Decoded into: FallbackRecipeDTO (Codable struct)")
        print("📍 Mapping to: Recipe (SwiftData @Model)")
        print("============================================")
        
        // Map author
        let authorName = author?.name ?? "Unknown"
        let recipeAuthor = Author(
            name: authorName,
            username: "@\(authorName.lowercased().replacingOccurrences(of: " ", with: ""))"
        )
        print("\n👤 AUTHOR:")
        print("   Raw author name: \(author?.name ?? "nil")")
        print("   Mapped name: \(recipeAuthor.name)")
        print("   Mapped username: \(recipeAuthor.username)")
        
        // Map image
        let coverUrl = image?.firstImageURL
        print("\n🖼️ IMAGE:")
        print("   Raw image data: \(String(describing: image))")
        print("   Extracted cover URL: \(coverUrl?.absoluteString ?? "nil")")
        
        // Map ingredients into groups + members vs. singles.
        //
        // GROUPING RULE (from the recipe spec):
        //   • A line with NO quantity is a GROUP HEADER and opens a new group.
        //   • A line WITH a quantity is either:
        //       – a MEMBER of the currently open group, or
        //       – a SINGLE top-level ingredient when no group is open yet
        //         (i.e. it appears before the first header).
        print("\n🥕 INGREDIENTS (raw → grouped):")
        var recipeIngredients: [Ingredient] = []
        var currentGroup: Ingredient? = nil

        for (index, rawIngredient) in (recipeIngredient ?? []).enumerated() {
            let parts = parseIngredientString(rawIngredient)
            let hasQuantity = !parts.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            print("   [\(index)] RAW: \"\(rawIngredient)\" → qty: \"\(parts.quantity)\" | name: \"\(parts.name)\"")

            if !hasQuantity && Self.isGroupHeader(parts.name) {
                // Group header — opens a new group.
                let group = Ingredient(quantity: "", name: parts.name, groupIngredients: [])
                recipeIngredients.append(group)
                currentGroup = group
                print("         ↳ GROUP HEADER")
            } else if let group = currentGroup {
                // Member of the currently open group.
                group.groupIngredients?.append(Ingredient(quantity: parts.quantity, name: parts.name))
                print("         ↳ MEMBER of \"\(group.name)\"")
            } else {
                // Single top-level ingredient (before any header).
                recipeIngredients.append(Ingredient(quantity: parts.quantity, name: parts.name))
                print("         ↳ SINGLE")
            }
        }
        
        // Map instructions
        print("\n📝 INSTRUCTIONS:")
        let recipeInstructionsList: [Instruction] = (recipeInstructions ?? []).enumerated().map { index, rawInstruction in
            let instructionText = rawInstruction.text ?? rawInstruction.name ?? ""
            let photoUrl = rawInstruction.image.flatMap { URL(string: $0) }
            print("   [\(index + 1)] text: \"\(instructionText.prefix(80))\(instructionText.count > 80 ? "..." : "")\"")
            if let photo = photoUrl {
                print("         photo: \(photo.absoluteString)")
            }
            return Instruction(
                sequenceNumber: index + 1,
                text: instructionText,
                photoUrl: photoUrl,
                breakdownInstruction: []
            )
        }
        
        // Parse duration
        let rawDuration = totalTime ?? cookTime ?? prepTime
        let duration = parseDuration(rawDuration)
        print("\n⏱️ DURATION:")
        print("   Raw totalTime: \(totalTime ?? "nil")")
        print("   Raw cookTime: \(cookTime ?? "nil")")
        print("   Raw prepTime: \(prepTime ?? "nil")")
        print("   Parsed minutes: \(duration)")
        
        // Parse yield
        let portion = recipeYield?.intValue ?? 0
        print("\n🍽️ YIELD:")
        print("   Raw recipeYield: \(String(describing: recipeYield))")
        print("   Parsed portion: \(portion)")
        
        let recipeName = name ?? "Resep Tanpa Judul"
        print("\n📌 TITLE: \"\(recipeName)\"")
        print("\n========== ✅ SCRAPE COMPLETE ==========")
        print("Total ingredients: \(recipeIngredients.count)")
        print("Total instructions: \(recipeInstructionsList.count)")
        print("========================================\n")
        
        var finalDuration = duration > 0 ? duration : 30
        if finalDuration > 120 {
            finalDuration = 121
        }
        
        return Recipe(
            title: recipeName,
            author: recipeAuthor,
            coverImageUrl: coverUrl,
            portion: 0,
            durationInMinutes: finalDuration,
            ingredients: recipeIngredients,
            instructions: recipeInstructionsList
        )
    }
    
    // MARK: - Helpers
    
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
        "pinch", "dash", "bunch", "can", "package", "packet"
    ]
    
    /// Check if a character is a digit or unicode fraction
    private func isQuantityChar(_ char: Character) -> Bool {
        return char.isNumber || char == "/" || char == "." || char == ","
            || char == "-" || char == "–" // range dashes
            || FallbackRecipeDTO.unicodeFractions[char] != nil
    }
    
    /// Parse an ingredient string like "10 siung Bawang Merah" into quantity and name.
    ///
    /// DATA FLOW: Each raw ingredient string from `recipeIngredient[]` in the JSON
    /// is split into (quantity, name). Example:
    ///   "10 siung Bawang Merah" → quantity: "10 siung", name: "Bawang Merah"
    ///   "½ sdt Garam" → quantity: "1/2 sdt", name: "Garam"
    ///   "Secukupnya Garam" → quantity: "Secukupnya", name: "Garam"
    private func parseIngredientString(_ raw: String) -> (quantity: String, name: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (quantity: "", name: trimmed)
        }
        
        // Replace unicode fractions with ASCII equivalents for consistency
        var normalized = trimmed
        for (unicodeFrac, replacement) in FallbackRecipeDTO.unicodeFractions {
            normalized = normalized.replacingOccurrences(of: String(unicodeFrac), with: replacement)
        }
        
        // Check if the first word is "Secukupnya" or similar standalone quantity word
        let words = normalized.components(separatedBy: " ").filter { !$0.isEmpty }
        guard !words.isEmpty else {
            return (quantity: "", name: trimmed)
        }
        
        let standaloneQuantityWords: Set<String> = ["secukupnya", "sejumput", "sesuai", "sedikit"]
        if standaloneQuantityWords.contains(words[0].lowercased()) {
            let qty = words[0]
            let name = words.dropFirst().joined(separator: " ")
            return (quantity: qty, name: name.isEmpty ? qty : name)
        }
        
        // Find where the numeric portion ends
        var quantityEndIndex = normalized.startIndex
        var foundDigit = false
        
        for (index, char) in normalized.enumerated() {
            if isQuantityChar(char) {
                foundDigit = true
                quantityEndIndex = normalized.index(normalized.startIndex, offsetBy: index + 1)
            } else if foundDigit && char == " " {
                // Check if the next word is a known unit
                let remaining = String(normalized[quantityEndIndex...]).trimmingCharacters(in: .whitespaces)
                let nextWords = remaining.components(separatedBy: " ").filter { !$0.isEmpty }
                let firstWord = nextWords.first?.lowercased() ?? ""
                
                if FallbackRecipeDTO.knownUnits.contains(firstWord) {
                    // Include the unit word in quantity
                    let unitEndOffset = index + 1 + firstWord.count + 1
                    if unitEndOffset <= normalized.count {
                        quantityEndIndex = normalized.index(normalized.startIndex, offsetBy: min(unitEndOffset, normalized.count))
                    }
                    // Check for a second unit word (e.g., "sendok makan")
                    if nextWords.count > 1 {
                        let secondWord = nextWords[1].lowercased()
                        let compoundUnits: Set<String> = ["makan", "teh", "makan", "besar", "kecil"]
                        if compoundUnits.contains(secondWord) {
                            let compoundOffset = unitEndOffset + secondWord.count + 1
                            if compoundOffset <= normalized.count {
                                quantityEndIndex = normalized.index(normalized.startIndex, offsetBy: min(compoundOffset, normalized.count))
                            }
                        }
                    }
                }
                break
            } else if !foundDigit {
                // No digit found at start — entire string is the name
                return (quantity: "", name: trimmed)
            }
        }
        
        let quantity = String(normalized[..<quantityEndIndex]).trimmingCharacters(in: .whitespaces)
        let name = String(normalized[quantityEndIndex...]).trimmingCharacters(in: .whitespaces)
        
        if quantity.isEmpty {
            return (quantity: "", name: trimmed)
        }
        
        return (quantity: quantity, name: name.isEmpty ? trimmed : name)
    }
    
    /// Parse ISO 8601 duration like "PT30M" or "PT1H30M" to minutes.
    private func parseDuration(_ isoString: String?) -> Int {
        guard let isoString = isoString else { return 30 }
        
        var minutes = 0
        let cleaned = isoString.uppercased().replacingOccurrences(of: "PT", with: "")
        
        // Extract hours
        if let hRange = cleaned.range(of: "(\\d+)H", options: .regularExpression) {
            let hourStr = cleaned[hRange].replacingOccurrences(of: "H", with: "")
            minutes += (Int(hourStr) ?? 0) * 60
        }
        
        // Extract minutes
        if let mRange = cleaned.range(of: "(\\d+)M", options: .regularExpression) {
            let minStr = cleaned[mRange].replacingOccurrences(of: "M", with: "")
            minutes += Int(minStr) ?? 0
        }
        
        return minutes > 0 ? minutes : 30
    }
}
