import Foundation

// MARK: - Flexible Author
/// Handles JSON-LD author field: a string, an object with "name", or an array of author objects
struct ScrapedAuthorDTO: Codable {
    let name: String

    init(name: String) {
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self.name = str
            return
        }
        if let obj = try? container.decode(AuthorObject.self) {
            self.name = obj.name ?? "Unknown"
            return
        }
        if let arr = try? container.decode([AuthorObject].self), let first = arr.first {
            self.name = first.name ?? "Unknown"
            return
        }
        self.name = "Unknown"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }

    private struct AuthorObject: Codable {
        let name: String?
    }
}
