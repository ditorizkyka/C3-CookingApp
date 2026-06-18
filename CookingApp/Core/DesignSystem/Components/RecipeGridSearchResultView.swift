import SwiftUI

struct RecipeGridSearchResultView: View {
    var searchQuery: String
    var filteredRecipes: [Recipe]
    var onTapRecipe: (Recipe) -> Void
    var onDeleteRecipe: ((Recipe) -> Void)? = nil
    
    var body: some View {
        if filteredRecipes.isEmpty {
            Spacer()
            ContentUnavailableView(
                "Tidak ada hasil untuk \"\(searchQuery)\"",
                systemImage: "magnifyingglass",
                description: Text("Coba periksa ejaan atau gunakan kata kunci lain.")
            )
            Spacer()
        } else {
            ScrollView {
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ]
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredRecipes.indices, id: \.self) { index in
                        let recipe = filteredRecipes[index]
                        let colors: [Color] = [.recipeCardBronze ?? .orange, .recipeCardCyan ?? .cyan, .recipeCardGreen ?? .green, .recipeCardPurple ?? .purple, .recipeCardRed ?? .red]
                        let color = colors[index % colors.count]
                        
                        RecipeCardSmall(
                            recipeTitle: recipe.title,
                            recipeCategoryIcon: "🍲",
                            imageName: nil,
                            imageUrl: recipe.coverImageUrl,
                            imageData: recipe.coverImageData,
                            recipeColor: color,
                            recipePortion: recipe.portion,
                            recipeDuration: recipe.durationInMinutes
                        )
                        .onTapGesture {
                            onTapRecipe(recipe)
                        }
                        // 👇 Di sini keajaibannya terjadi
                        .contextMenu {
                            Button(role: .destructive) {
                                onDeleteRecipe?(recipe)
                            } label: {
                                Label("Delete Recipe", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
