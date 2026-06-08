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
    
    // Untuk menutup sheet
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        ZStack {
            Color.surfaceElevated
            VStack(spacing: 32) {
                ZStack {
                    // Judul di tengah
                    Text("Import Resep")
                        .font(.headline) // Atau .title3
                    
                    // Tombol X di ujung kiri
                    HStack {
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(width: 45, height: 45)
                                .background(Color(UIColor.tertiarySystemFill)) // Warna bulat abu-abu
                                .clipShape(Circle())
                        }
                        Spacer() // Mendorong tombol ke ujung kiri
                    }
                }
                
                VStack(spacing:16) {
                    Text("Masukkan link resep (cth: Cookpad) untuk memproses bahan dan panduan masak secara otomatis")
                        .font(.body)
                    TextField("", text: $link)
                        .padding(.horizontal,15)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Color(UIColor.tertiarySystemFill)
                        )
                        .cornerRadius(Radius.infinity)
                    
                    
                }
                VStack(spacing: 8,) {
                    ButtonApp(title: "Import Recipe", action: {
                        showPreviewSheet = true
                    })
                    ButtonApp(title: "Cancel", type: .tertiary, action: {
                        print("cancel")
                    })
                }
            }
//            .padding(.vertical, 8)
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
            
        }
        .ignoresSafeArea()
        
        
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
