//
//  WebsitePreviewSheet.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 06/06/26.
//


//
//  WebsitePreviewSheet.swift
//  TechnicalFeasibility - Challenge 1 / Cookpad Scraper
//
//  EXPLANATION FOR LEARNER:
//  This view displays the WKWebView in a sheet format.
//  It includes a prominent "Import" button at the bottom so users
//  can confirm they want to scrape this recipe after previewing it.
//

import SwiftUI

struct WebsitePreviewSheet: View {
    let urlString: String
    let onImport: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // The actual website preview
                if let url = URL(string: urlString) {
                    WebView(url: url)
                        .edgesIgnoringSafeArea(.bottom)
                } else {
                    Text("Invalid URL")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Bottom Import Bar
                VStack {
                    ButtonApp(title: "Simpan Resep", type: .primary, action: onImport,) // Safe area handled by container
                }
                .background(Color(.systemBackground).shadow(radius: 5))
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }
}
