import Foundation

// MARK: - Flexible Double
/// Handles JSON values that can be either a number or a string representation of a number
struct ScrapedDoubleDTO: Codable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dbl = try? container.decode(Double.self) {
            self.value = dbl
        } else if let str = try? container.decode(String.self), let dbl = Double(str) {
            self.value = dbl
        } else {
            self.value = 0
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
