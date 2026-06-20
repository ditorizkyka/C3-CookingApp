import SwiftUI

enum RecipeCategory: String, Codable, CaseIterable {
    case ayamBebek = "Ayam / Bebek"
    case daging = "Daging"
    case vegetarian = "Vegetarian"
    case seafood = "Seafood / Ikan"
    case lainnya = "Lainnya"
    
    var icon: String {
        switch self {
        case .ayamBebek: return "🍗"
        case .daging: return "🍖"
        case .vegetarian: return "🥦"
        case .seafood: return "🐟"
        case .lainnya: return "🍴"
        }
    }
    
    var color: Color {
        switch self {
        case .ayamBebek: return .recipeCardBronze
        case .daging: return .recipeCardRed
        case .vegetarian: return .recipeCardGreen
        case .seafood: return .recipeCardCyan
        case .lainnya: return .recipeCardPurple
        }
    }
    
    static func guessCategory(from title: String) -> RecipeCategory {
        let lowercasedTitle = title.lowercased()
        
        let ayamBebekKeywords = ["ayam", "bebek", "chicken", "duck", "kalkun"]
        let dagingKeywords = ["daging", "sapi", "kambing", "babi", "beef", "pork", "mutton", "iga", "buntut", "rawon", "rendang", "steak", "meatballs", "bakso"]
        let seafoodKeywords = ["ikan", "udang", "cumi", "kerang", "kepiting", "fish", "shrimp", "seafood", "salmon", "tuna", "gurame", "lele", "nila", "bandeng", "teri", "tongkol", "prawn", "squid"]
        let vegetarianKeywords = ["sayur", "tahu", "tempe", "salad", "tofu", "bayam", "kangkung", "brokoli", "wortel", "pecel", "gado", "karedok", "vegan"]
        
        if dagingKeywords.contains(where: { lowercasedTitle.contains($0) }) {
            return .daging
        } else if ayamBebekKeywords.contains(where: { lowercasedTitle.contains($0) }) {
            return .ayamBebek
        } else if seafoodKeywords.contains(where: { lowercasedTitle.contains($0) }) {
            return .seafood
        } else if vegetarianKeywords.contains(where: { lowercasedTitle.contains($0) }) {
            return .vegetarian
        }
        
        return .lainnya
    }
}
