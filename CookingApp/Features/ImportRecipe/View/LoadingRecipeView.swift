import SwiftUI
import Translation

struct LoadingRecipeView: View {
    let urlToScrape: String
    var onScrapingComplete: ((Recipe) -> Void)? = nil
    var onError: ((String) -> Void)? = nil
    
    @StateObject private var viewModel = LoadingRecipeViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            if let errorMessage = viewModel.errorMessage {
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
                        viewModel.errorMessage = nil
                        viewModel.startScraping(url: urlToScrape, onError: onError)
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
            viewModel.startScraping(url: urlToScrape, onError: onError)
        }

        .translationTask(viewModel.configIdToEn) { session in
            await viewModel.translateToEnglish(session: session)
        }
        .translationTask(viewModel.configEnToId) { session in
            await viewModel.translateToIndonesian(session: session, onComplete: onScrapingComplete)
        }
    }
}

#Preview {
    NavigationStack {
        LoadingRecipeView(urlToScrape: "https://cookpad.com/id/resep/example")
    }
}
