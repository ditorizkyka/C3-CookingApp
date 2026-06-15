//
//  HomeViewModel.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 10/06/26.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchRecipe: String = ""
    @Published var isSearchActive: Bool = false
    @Published var selectedIndex: Int? = nil
    
    // Navigation states
    @Published var navigateToManual = false
    @Published var navigateToDetail = false
    @Published var navigateToLoading = false
    @Published var navigateToLibrary = false
    
    // Sheet states
    @Published var isShowingImportSheet = false
    @Published var showWebPreviewFromClipboard = false
    
    // Import flow states
    @Published var urlToScrape: String = ""
    @Published var importedRecipe: Recipe?
    @Published var importedLink: String = ""
    
    func filteredRecipes(from allRecipes: [Recipe]) -> [Recipe] {
        if searchRecipe.isEmpty {
            return allRecipes
        } else {
            return allRecipes.filter { $0.title.localizedCaseInsensitiveContains(searchRecipe) }
        }
    }
    
    func resetNavigation() {
        navigateToDetail = false
        navigateToLoading = false
        navigateToLibrary = false
        navigateToManual = false
    }
    
    func handleImport(url: String) {
        urlToScrape = url
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigateToLoading = true
        }
    }
    
    func handleClipboardImport(url: String) {
        showWebPreviewFromClipboard = false
        urlToScrape = url
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigateToLoading = true
        }
    }
    
    func handleScrapingComplete(recipe: Recipe) {
        importedRecipe = recipe
        navigateToLoading = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigateToDetail = true
        }
    }
    
    func handleManualRecipeComplete(recipe: Recipe) {
        importedRecipe = recipe
        navigateToManual = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigateToDetail = true
        }
    }
    
    func dismissDetail() {
        navigateToDetail = false
        importedRecipe = nil // Reset agar tidak bocor
    }
}
