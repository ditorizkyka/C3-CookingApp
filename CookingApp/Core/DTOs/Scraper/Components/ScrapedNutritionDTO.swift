import Foundation

// MARK: - Nutrition Info
struct ScrapedNutritionDTO: Codable {
    let calories: String?
    let fatContent: String?
    let carbohydrateContent: String?
    let proteinContent: String?
    let fiberContent: String?
    let sugarContent: String?
    let sodiumContent: String?
    let cholesterolContent: String?
    let saturatedFatContent: String?
    let unsaturatedFatContent: String?
    let transFatContent: String?
    let servingSize: String?
}
