import Foundation
import SwiftData

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
