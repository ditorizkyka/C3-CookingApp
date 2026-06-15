import Foundation
import SwiftData

// MARK: - Recipe
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
    @Relationship(deleteRule: .cascade) var instructions: [Instruction]
    
    var tips: String?
    
    /// Locally stored cover image data (when user picks a photo from library)
    var coverImageData: Data?
    
    init(id: UUID = UUID(), title: String, author: Author? = nil, coverImageUrl: URL? = nil, coverImageData: Data? = nil, portion: Int, durationInMinutes: Int, ingredients: [Ingredient] = [], instructions: [Instruction] = [], tips: String? = nil) {
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
    }
}

// MARK: - Author
@Model
class Author: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var username: String
    var avatarUrl: URL?
    
    init(id: UUID = UUID(), name: String, username: String, avatarUrl: URL? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarUrl = avatarUrl
    }
}

// MARK: - Ingredient
@Model
class Ingredient: Identifiable {
    @Attribute(.unique) var id: UUID
    var quantity: String
    var name: String
    
    // Relasi rekursif (Ingredient punya sub-Ingredient)
    @Relationship(deleteRule: .cascade) var groupIngredients: [Ingredient]?
    
    // Computed property tidak akan disimpan ke database (diabaikan oleh SwiftData)
    var isGroup: Bool {
        return groupIngredients != nil && !(groupIngredients?.isEmpty ?? true)
    }
    
    init(id: UUID = UUID(), quantity: String, name: String, groupIngredients: [Ingredient]? = nil) {
        self.id = id
        self.quantity = quantity
        self.name = name
        self.groupIngredients = groupIngredients
    }
}

// MARK: - Instruction
@Model
class Instruction: Identifiable {
    @Attribute(.unique) var id: UUID
    var sequenceNumber: Int
    var text: String
    var photoUrl: URL?
    
    // Relasi rekursif untuk sub-langkah
    @Relationship(deleteRule: .cascade) var breakdownInstruction: [Instruction]
    
    init(id: UUID = UUID(), sequenceNumber: Int, text: String, photoUrl: URL? = nil, breakdownInstruction: [Instruction] = []) {
        self.id = id
        self.sequenceNumber = sequenceNumber
        self.text = text.removingEmojis().trimmingCharacters(in: .whitespacesAndNewlines)
        self.photoUrl = photoUrl
        self.breakdownInstruction = breakdownInstruction
    }
}

extension String {
    func removingEmojis() -> String {
        return self.unicodeScalars.filter { !$0.properties.isEmojiPresentation }.map(String.init).joined()
    }
}
