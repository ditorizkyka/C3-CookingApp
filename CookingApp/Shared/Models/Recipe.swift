import Foundation
import SwiftData

@Model
class Recipe: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    
    // Relasi ke Author
    @Relationship(deleteRule: .cascade) var author: Author?
    var coverImageUrl: URL?
    var portion: Int
    var durationInMinutes: Int
    
    // Cascade berarti jika Recipe dihapus, ingredients & instructions ini ikut terhapus
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    
    // Ingredients sorted by their intended order
    var sortedIngredients: [Ingredient] {
        ingredients.sorted { $0.sequenceNumber < $1.sequenceNumber }
    }
    
    @Relationship(deleteRule: .cascade) var instructions: [Instruction]
    
    // Instructions sorted by their intended order
    var sortedInstructions: [Instruction] {
        instructions.sorted { $0.sequenceNumber < $1.sequenceNumber }
    }
    
    var tips: String?
    var categoryRawValue: String?
    
    // Computed property to prevent SwiftData migration crash for existing nil values
    var category: RecipeCategory {
        get {
            guard let rawValue = categoryRawValue, let cat = RecipeCategory(rawValue: rawValue) else {
                return .lainnya
            }
            return cat
        }
        set {
            categoryRawValue = newValue.rawValue
        }
    }
    
    /// Locally stored cover image data (when user picks a photo from library)
    var coverImageData: Data?
    
    init(id: UUID = UUID(), title: String, author: Author? = nil, coverImageUrl: URL? = nil, coverImageData: Data? = nil, portion: Int, durationInMinutes: Int, ingredients: [Ingredient] = [], instructions: [Instruction] = [], tips: String? = nil, category: RecipeCategory = .lainnya) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageUrl = coverImageUrl
        self.coverImageData = coverImageData
        self.portion = portion
        self.durationInMinutes = durationInMinutes
        self.ingredients = ingredients
        self.instructions = instructions
        self.tips = tips
        
        if category == .lainnya {
            self.categoryRawValue = RecipeCategory.guessCategory(from: title).rawValue
        } else {
            self.categoryRawValue = category.rawValue
        }
    }
}
