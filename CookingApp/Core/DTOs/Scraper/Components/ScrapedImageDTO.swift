import Foundation

// MARK: - Flexible Image
/// Handles JSON-LD image field which can be: a string URL, an object with "url" key, an array of strings, or an array of objects
struct ScrapedImageDTO: Codable {
    let url: String
    let allURLs: [String]

    init(url: String) {
        self.url = url
        self.allURLs = [url]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let urlString = try? container.decode(String.self) {
            self.url = urlString
            self.allURLs = [urlString]
            return
        }
        if let obj = try? container.decode(ImageObject.self) {
            self.url = obj.url ?? ""
            self.allURLs = [obj.url ?? ""]
            return
        }
        if let arr = try? container.decode([String].self) {
            self.url = arr.first ?? ""
            self.allURLs = arr
            return
        }
        if let arr = try? container.decode([ImageObject].self) {
            let urls = arr.compactMap { $0.url }
            self.url = urls.first ?? ""
            self.allURLs = urls
            return
        }
        self.url = ""
        self.allURLs = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }

    private struct ImageObject: Codable {
        let url: String?
    }
}
