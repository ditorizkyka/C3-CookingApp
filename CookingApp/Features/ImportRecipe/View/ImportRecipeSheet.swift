//
//  ImportRecipeSheet.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//

import SwiftUI

struct ImportRecipeSheet: View {
    
    @State var link: String = ""
    @State private var showPreviewSheet = false
    @State private var previewUrlString: String = ""
//    @State private var scrapedRecipe: Recipe?
    @State private var recipeLink = "https://cookpad.com/id/resep/17154212-nasi-goreng-kampung"
    
    @State private var isLoading = false
    @State private var errorMessage: String?

    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing:16) {
                    Text("Masukkan link resep (cth: Cookpad) untuk memproses bahan dan panduan masak secara otomatis")
                        .font(.body)
                    TextField("Cari sesuatu...", text: $link)
                        .padding(.horizontal,15)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Color.surfaceDefault
                        )
                        .cornerRadius(Radius.small)
                    
                    
                }
                .padding(.bottom, 16)
                VStack(spacing: 8,) {
                    ButtonApp(title: "Import Recipe", action: {
                        showPreviewSheet = true
                    })
                    ButtonApp(title: "Cancel", type: .secondary, action: {
                        print("cancel")
                    })
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal,24)
            // Preview Sheet
            .sheet(isPresented: $showPreviewSheet) {
                WebsitePreviewSheet(
                    urlString: previewUrlString,
                    onImport: {
                        showPreviewSheet = false
                        //                    recipeLink = previewUrlString
                        //                    Task {
                        //                        // Small delay to allow sheet to dismiss before starting async scrape
                        //                        try? await Task.sleep(nanoseconds: 300_000_000)
                        //                        await startScraping()
                        //                    }
                    },
                    onDismiss: {
                        showPreviewSheet = false
                    }
                )
            }
            .navigationTitle("Import Recipe")
        }
        
    
    }
    
//    // MARK: - Start Scraping
//    @MainActor
//    private func startScraping() async {
//        isLoading = true
//        scrapedRecipe = nil
//        errorMessage = nil
//
//        do {
//            let result = try await CookpadScraperService.shared.scrape(urlString: recipeLink)
//            scrapedRecipe = result
//        } catch let error as ScraperError {
//            errorMessage = error.errorDescription
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//
//        isLoading = false
//    }
    
    
}

#Preview {
    ImportRecipeSheet()
}
