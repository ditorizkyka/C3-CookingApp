import SwiftUI

struct LoadingRecipeView: View {
    let urlToScrape: String
    var onScrapingComplete: ((Recipe) -> Void)? = nil
    var onError: ((String) -> Void)? = nil
    
    @State private var scrapedRecipe: Recipe?
    @State private var errorMessage: String?
    @State private var navigateToDetail = false
    
    var body: some View {
        VStack(spacing: 24) {
            if let errorMessage = errorMessage {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.brandSecondary!)
                    
                    Text("Gagal Mengekstrak Resep")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelDark!)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(Color.labelLight!)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ButtonApp(title: "Coba Lagi", action: {
                        self.errorMessage = nil
                        startScraping()
                    })
                    .padding(.horizontal, 40)
                }
            } else {
                // Loading state
                ProgressView()
                    .scaleEffect(2)
                    .tint(Color.brandPrimary!)
                Text("Mengekstrak Resep...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelDark!)
                
                Text("Memproses bahan dan langkah memasak")
                    .font(.subheadline)
                    .foregroundColor(Color.labelLight!)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceDefault.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startScraping()
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let recipe = scrapedRecipe {
                DetailRecipeView(recipe: recipe, isFromImport: true)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // MARK: - Scraping
    private func startScraping() {
        Task { @MainActor in
            do {
                let result = try await CookpadScraperService.shared.scrape(urlString: urlToScrape)
                scrapedRecipe = result
                onScrapingComplete?(result)
                navigateToDetail = true
            } catch let error as ScraperError {
                errorMessage = error.errorDescription
                onError?(error.errorDescription ?? "Unknown error")
            } catch {
                errorMessage = error.localizedDescription
                onError?(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoadingRecipeView(urlToScrape: "https://cookpad.com/id/resep/example")
    }
}
