//
//  ImportRecipeViewModel.swift
//  CookingApp
//
//  Created for Import Recipe flow.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ImportRecipeViewModel: ObservableObject {
    @Published var link: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var scrapedRecipe: Recipe?
    
    @Published var showWebPreview: Bool = false
    @Published var showLoading: Bool = false
    @Published var showDetailPreview: Bool = false
    @Published var scrapingFinished: Bool = false
    
    // MARK: - Validation
    
    /// Check if the entered link is a valid Cookpad URL
    var isValidCookpadLink: Bool {
        let cleaned = link.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let url = URL(string: cleaned), let host = url.host?.lowercased() else {
            return false
        }
        return host.contains("cookpad.com")
    }
    
    /// Validate the link and show the web preview if valid
    func validateAndShowPreview() {
        errorMessage = nil
        
        let cleaned = link.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        guard !cleaned.isEmpty else {
            errorMessage = "Masukkan link resep terlebih dahulu."
            return
        }
        
        // Add https:// if missing
        var urlString = cleaned
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        // Validate URL format
        guard URL(string: urlString) != nil else {
            errorMessage = "Format URL tidak valid."
            return
        }
        
        // Check if it's a Cookpad URL
        // guard CookpadScraperService.isValidCookpadURL(urlString) else {
        //     errorMessage = "Saat ini hanya mendukung link dari Cookpad. Pastikan link berasal dari cookpad.com."
        //     return
        // }
        
        // Update link with the cleaned/prefixed version
        link = urlString
        showWebPreview = true
    }
    
    // MARK: - Scraping
    
    /// Start scraping the Cookpad recipe
    func startScraping() async {
        isLoading = true
        scrapedRecipe = nil
        errorMessage = nil
        scrapingFinished = false
        
        do {
            let result = try await CookpadScraperService.shared.scrape(urlString: link)
            scrapedRecipe = result
            scrapingFinished = true
        } catch let error as ScraperError {
            errorMessage = error.errorDescription
            scrapingFinished = true
        } catch {
            errorMessage = error.localizedDescription
            scrapingFinished = true
        }
        
        isLoading = false
    }
}
