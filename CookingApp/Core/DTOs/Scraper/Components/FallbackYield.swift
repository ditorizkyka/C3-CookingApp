import Foundation

// MARK: - Yield (can be string or number)
enum FallbackYield: Codable {
    case string(String)
    case number(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .number(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else {
            self = .string("0")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
    
    var intValue: Int {
        switch self {
        case .number(let val): return val
        case .string(let str):
            // Extract first number from string like "4 porsi" or "4"
            let digits = str.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(digits) ?? 0
        }
    }
}
