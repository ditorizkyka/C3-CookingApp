import Foundation

// MARK: - Image (can be string or array of strings)
enum FallbackImage: Codable {
    case single(String)
    case multiple([String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let single = try? container.decode(String.self) {
            self = .single(single)
        } else if let multiple = try? container.decode([String].self) {
            self = .multiple(multiple)
        } else {
            self = .single("")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .multiple(let values):
            try container.encode(values)
        }
    }
    
    var firstImageURL: URL? {
        switch self {
        case .single(let urlString):
            return URL(string: urlString)
        case .multiple(let urlStrings):
            return urlStrings.first.flatMap { URL(string: $0) }
        }
    }
}
