import Foundation
import SwiftData

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
