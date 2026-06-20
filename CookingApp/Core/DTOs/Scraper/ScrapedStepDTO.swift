import Foundation

// MARK: - Scraped Step (handles HowToStep, HowToSection, plain strings)
/// Handles the many formats websites use for recipeInstructions:
/// - Plain string: "Boil the water"
/// - HowToStep object: { "@type": "HowToStep", "text": "Boil the water" }
/// - HowToSection with nested HowToSteps
struct ScrapedStepDTO: Codable, Identifiable {
    let id: UUID
    let text: String?
    let name: String?
    let image: String?
    let isSection: Bool
    var itemListElement: [ScrapedStepDTO]? = nil

    enum CodingKeys: String, CodingKey {
        case text, name, image
        case type = "@type"
        case itemListElement
    }

    init(text: String?, name: String? = nil, image: String? = nil, isSection: Bool = false) {
        self.id = UUID()
        self.text = text
        self.name = name
        self.image = image
        self.isSection = isSection
    }

    init(from decoder: Decoder) throws {
        self.id = UUID()

        // Handle plain string format: "Boil the water"
        if let container = try? decoder.singleValueContainer(),
           let str = try? container.decode(String.self) {
            self.text = str
            self.name = nil
            self.image = nil
            self.isSection = false
            return
        }

        // Handle object format: { "@type": "HowToStep", "text": "..." }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)

        if let imgStr = try? container.decode(String.self, forKey: .image) {
            self.image = imgStr
        } else if let imgObj = try? container.decode(ScrapedImageDTO.self, forKey: .image) {
            self.image = imgObj.url
        } else {
            self.image = nil
        }

        self.itemListElement = try container.decodeIfPresent([ScrapedStepDTO].self, forKey: .itemListElement)
        self.isSection = (type == "HowToSection" || (self.itemListElement != nil && self.name != nil))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(itemListElement, forKey: .itemListElement)
    }

    // MARK: - Flatten Helper
    /// Recursively flattens HowToSection → HowToStep hierarchy into a flat array
    static func flatten(_ steps: [ScrapedStepDTO]?) -> [ScrapedStepDTO]? {
        guard let steps = steps else { return nil }
        var result: [ScrapedStepDTO] = []

        for step in steps {
            if step.text != nil || step.name != nil {
                result.append(step)
            }
            if let nestedItems = step.itemListElement {
                if let flattenedNested = flatten(nestedItems) {
                    result.append(contentsOf: flattenedNested)
                }
            }
        }

        return result.isEmpty ? nil : result
    }
}
