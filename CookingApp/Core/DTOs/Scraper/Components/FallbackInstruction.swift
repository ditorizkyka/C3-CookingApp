import Foundation

// MARK: - Instruction
struct FallbackInstruction: Codable {
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
