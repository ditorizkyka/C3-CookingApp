import SwiftUI

struct LoadingRecipeView: View {
    let urlToScrape: String
    var onScrapingComplete: ((Recipe) -> Void)? = nil
    var onError: ((String) -> Void)? = nil
    
    @StateObject private var viewModel = LoadingRecipeViewModel()
    @State private var navigateToBreakdown = false
    @State private var scrapedRecipe: Recipe?
    
    var body: some View {
        VStack(spacing: 24) {
            if let errorMessage = viewModel.errorMessage {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.brandSecondary)
                    
                    Text("Gagal Mengekstrak Resep")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelDark)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(Color.labelLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ButtonApp(title: "Coba Lagi", action: {
                        viewModel.errorMessage = nil
                        viewModel.startScraping(
                            url: urlToScrape,
                            onComplete: { recipe in
                                self.scrapedRecipe = recipe
                                self.navigateToBreakdown = true
                            },
                            onError: onError
                        )
                    })
                    .padding(.horizontal, 40)
                }
            } else {
                // Loading state
                ProgressView()
                    .scaleEffect(2)
                    .tint(Color.brandPrimary)
                Text("Mengekstrak Resep...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelDark)
                
                Text("Memproses bahan dan instruksi dari website")
                    .font(.subheadline)
                    .foregroundColor(Color.labelLight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceDefault.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startScraping(
                url: urlToScrape,
                onComplete: { recipe in
                    self.scrapedRecipe = recipe
                    self.navigateToBreakdown = true
                },
                onError: onError
            )
        }
        .navigationDestination(isPresented: $navigateToBreakdown) {
            if let recipe = scrapedRecipe {
                BreakdownLoadingView(
                    recipe: recipe,
                    onBreakdownComplete: onScrapingComplete,
                    onError: onError
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoadingRecipeView(urlToScrape: "https://cookpad.com/id/resep/example")
    }
}
