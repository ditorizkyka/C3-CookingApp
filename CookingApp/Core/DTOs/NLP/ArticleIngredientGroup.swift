import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.1, *)
@Generable
struct ArticleIngredientGroup: Codable {
    @Guide(description: "The name of the group or category. If the ingredients are a flat list without headers, this MUST be an empty string (\"\"). Do NOT invent group names.")
    var groupName: String
    
    @Guide(description: "The list of raw ingredients that belong to this group.")
    var ingredients: [String]
}
#endif
