import Foundation
import SwiftData

@Model
class Ingredient: Identifiable {
    @Attribute(.unique) var id: UUID
    var quantity: String
    var name: String
    var sequenceNumber: Int = 0
    
    // Relasi rekursif (Ingredient punya sub-Ingredient)
    @Relationship(deleteRule: .cascade) var groupIngredients: [Ingredient]?
    
    // Group ingredients sorted by their intended order
    var sortedGroupIngredients: [Ingredient]? {
        groupIngredients?.sorted { $0.sequenceNumber < $1.sequenceNumber }
    }
    
    // Computed property tidak akan disimpan ke database (diabaikan oleh SwiftData)
    var isGroup: Bool {
        return groupIngredients != nil && !(groupIngredients?.isEmpty ?? true)
    }
    
    init(id: UUID = UUID(), quantity: String, name: String, sequenceNumber: Int = 0, groupIngredients: [Ingredient]? = nil) {
        self.id = id
        self.quantity = quantity
        self.name = name
        self.sequenceNumber = sequenceNumber
        self.groupIngredients = groupIngredients
    }
}
