import Foundation
import SwiftData

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
