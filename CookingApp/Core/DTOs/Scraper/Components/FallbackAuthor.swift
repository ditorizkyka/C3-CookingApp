import Foundation

// MARK: - Author
struct FallbackAuthor: Codable {
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
