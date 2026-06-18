//
//  RecipeLibraryView.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI
import SwiftData

struct RecipeLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allRecipes: [Recipe]
    @StateObject private var viewModel = RecipeLibraryViewModel()
    
    var body: some View {
        let filtered = viewModel.getFilteredRecipes(from: allRecipes)
        
        RecipeGridSearchResultView(
            searchQuery: viewModel.searchRecipe,
            filteredRecipes: filtered,
            onTapRecipe: { recipe in
                viewModel.selectRecipe(recipe: recipe, in: filtered)
            },
            onDeleteRecipe: { recipe in
                viewModel.confirmDelete(recipe: recipe)
            }
        )
        .navigationTitle("Semua Resep")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                RecipeLibrarySortMenu(viewModel: viewModel)
            }
        }
        .searchable(
            text: $viewModel.searchRecipe,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Cari resep..."
        )
        .navigationDestination(isPresented: $viewModel.navigateToDetail) {
            if let index = viewModel.selectedIndex, index < filtered.count {
                let selectedRecipe = filtered[index]
                DetailRecipeView(recipe: selectedRecipe, onDismiss: { viewModel.dismissDetail() })
            }
        }
        .alert(
            "Apakah kamu yakin ingin menghapus resep \(viewModel.recipeToDelete?.title ?? "")?",
            isPresented: $viewModel.showDeleteConfirmation
        ) {
            Button("Batal", role: .cancel) {
                viewModel.recipeToDelete = nil
            }
            Button("Hapus", role: .destructive) {
                viewModel.deleteRecipe(context: modelContext)
            }
        } message: {
            Text("Resep ini akan dihapus secara permanen dari perpustakaan Anda dan tidak dapat dikembalikan.")
        }
    }
}

#Preview {
    NavigationStack {
        RecipeLibraryView()
    }
    .modelContainer(PreviewContainer.shared)
}
