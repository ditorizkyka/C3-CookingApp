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
struct CookpadRawRecipe: Codable {
    let name: String?
    let author: CookpadRawAuthor?
    let image: CookpadImage?
    let recipeYield: CookpadYield?
    let totalTime: String?
    let cookTime: String?
    let prepTime: String?
    let recipeIngredient: [String]?
    let recipeInstructions: [CookpadRawInstruction]?
    
    enum CodingKeys: String, CodingKey {
        case name, author, image
        case recipeYield, totalTime, cookTime, prepTime
        case recipeIngredient, recipeInstructions
    }
}

// MARK: - Author
struct CookpadRawAuthor: Codable {
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    // Handle both string and object formats
    init(from decoder: Decoder) throws {
        // Try decoding as a keyed container (object)
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.name = try? container.decode(String.self, forKey: .name)
        }
        // Try decoding as a single string value
        else if let singleValue = try? decoder.singleValueContainer(),
                let stringValue = try? singleValue.decode(String.self) {
            self.name = stringValue
        } else {
            self.name = nil
        }
    }
}

// MARK: - Image (can be string or array of strings)
enum CookpadImage: Codable {
    case single(String)
    case multiple([String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let single = try? container.decode(String.self) {
            self = .single(single)
        } else if let multiple = try? container.decode([String].self) {
            self = .multiple(multiple)
        } else {
            self = .single("")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .multiple(let values):
            try container.encode(values)
        }
    }
    
    var firstImageURL: URL? {
        switch self {
        case .single(let urlString):
            return URL(string: urlString)
        case .multiple(let urlStrings):
            return urlStrings.first.flatMap { URL(string: $0) }
        }
    }
}

// MARK: - Yield (can be string or number)
enum CookpadYield: Codable {
    case string(String)
    case number(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .number(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else {
            self = .string("1")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
    
    var intValue: Int {
        switch self {
        case .number(let val): return val
        case .string(let str):
            // Extract first number from string like "4 porsi" or "4"
            let digits = str.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(digits) ?? 1
        }
    }
}

// MARK: - Instruction
struct CookpadRawInstruction: Codable {
    let text: String?
    let name: String?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case text, name, image
    }
    
    // Handle both string and object formats
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.text = try? container.decode(String.self, forKey: .text)
            self.name = try? container.decode(String.self, forKey: .name)
            self.image = try? container.decode(String.self, forKey: .image)
        } else if let singleValue = try? decoder.singleValueContainer(),
                  let stringValue = try? singleValue.decode(String.self) {
            self.text = stringValue
            self.name = nil
            self.image = nil
        } else {
            self.text = nil
            self.name = nil
            self.image = nil
        }
    }
}

// MARK: - Mapping to App's SwiftData Model
extension CookpadRawRecipe {
    
    /// Convert scraped Cookpad LD+JSON data into the app's SwiftData `Recipe` model.
    func toRecipe() -> Recipe {
        // Map author
        let recipeAuthor = Author(
            name: author?.name ?? "Unknown",
            username: "@\(author?.name?.lowercased().replacingOccurrences(of: " ", with: "") ?? "unknown")"
        )
        
        // Map ingredients
        let recipeIngredients: [Ingredient] = (recipeIngredient ?? []).map { rawIngredient in
            let parts = parseIngredientString(rawIngredient)
            return Ingredient(
                quantity: parts.quantity,
                name: parts.name
            )
        }
        
        // Map instructions
        let recipeInstructionsList: [Instruction] = (recipeInstructions ?? []).enumerated().map { index, rawInstruction in
            let instructionText = rawInstruction.text ?? rawInstruction.name ?? ""
            let photoUrl = rawInstruction.image.flatMap { URL(string: $0) }
            return Instruction(
                sequenceNumber: index + 1,
                text: instructionText,
                photoUrl: photoUrl,
                breakdownInstruction: []
            )
        }
        
        // Parse duration
        let duration = parseDuration(totalTime ?? cookTime ?? prepTime)
        
        // Parse yield
        let portion = recipeYield?.intValue ?? 1
        
        return Recipe(
            title: name ?? "Resep Tanpa Judul",
            author: recipeAuthor,
            coverImageUrl: image?.firstImageURL,
            portion: portion,
            durationInMinutes: duration,
            ingredients: recipeIngredients,
            instructions: recipeInstructionsList
        )
    }
    
    // MARK: - Helpers
    
    /// Parse an ingredient string like "10 siung Bawang Merah" into quantity and name.
    private func parseIngredientString(_ raw: String) -> (quantity: String, name: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to split: find where quantity ends and name begins
        // Quantity is typically numbers + unit at the start
        var quantityEndIndex = trimmed.startIndex
        var foundDigit = false
        
        for (index, char) in trimmed.enumerated() {
            if char.isNumber || char == "/" || char == "." || char == "," {
                foundDigit = true
                quantityEndIndex = trimmed.index(trimmed.startIndex, offsetBy: index + 1)
            } else if foundDigit && char == " " {
                // Check if next word is a unit
                let remaining = String(trimmed[quantityEndIndex...]).trimmingCharacters(in: .whitespaces)
                let units = ["sdm", "sdt", "ml", "gram", "g", "kg", "liter", "l", "buah", "siung", "butir", "lembar", "batang", "bungkus", "sendok", "cup", "cups", "tbsp", "tsp", "oz", "lb", "cc"]
                let firstWord = remaining.components(separatedBy: " ").first?.lowercased() ?? ""
                if units.contains(firstWord) {
                    // Include the unit word in quantity
                    let unitEndOffset = index + 1 + firstWord.count + 1 // +1 for space
                    if unitEndOffset <= trimmed.count {
                        quantityEndIndex = trimmed.index(trimmed.startIndex, offsetBy: min(unitEndOffset, trimmed.count))
                    }
                }
                break
            } else if !foundDigit {
                // Name starts from the beginning (no quantity)
                return (quantity: "", name: trimmed)
            }
        }
        
        let quantity = String(trimmed[..<quantityEndIndex]).trimmingCharacters(in: .whitespaces)
        let name = String(trimmed[quantityEndIndex...]).trimmingCharacters(in: .whitespaces)
        
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
