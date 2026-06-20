import Foundation

// MARK: - Flexible String
/// Handles JSON-LD fields that can be: a string, an array of strings, or a number
struct ScrapedStringDTO: Codable {
    let value: String
    let allValues: [String]

    init(value: String) {
        self.value = value
        self.allValues = [value]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self.value = str
            self.allValues = [str]
            return
        }
        if let arr = try? container.decode([String].self) {
            self.value = arr.joined(separator: ", ")
            self.allValues = arr
            return
        }
        if let intVal = try? container.decode(Int.self) {
            self.value = "\(intVal)"
            self.allValues = ["\(intVal)"]
            return
        }
        self.value = ""
        self.allValues = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
