import Foundation

// MARK: - Aggregate Rating
struct ScrapedRatingDTO: Codable {
    let ratingValue: ScrapedDoubleDTO?
    let ratingCount: ScrapedDoubleDTO?
    let reviewCount: ScrapedDoubleDTO?
    let bestRating: ScrapedDoubleDTO?
}
