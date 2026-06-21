import SwiftUI
import Translation

struct ImportLoadingView: View {
    var urlToScrape: String? = nil
    var initialRecipe: Recipe? = nil
    var onComplete: ((Recipe) -> Void)? = nil
    
    @StateObject private var viewModel: ImportLoadingViewModel
    @Environment(\.dismiss) var dismiss
    
    init(urlToScrape: String? = nil, initialRecipe: Recipe? = nil, onComplete: ((Recipe) -> Void)? = nil) {
        self.urlToScrape = urlToScrape
        self.initialRecipe = initialRecipe
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: ImportLoadingViewModel(recipe: initialRecipe))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if let errorMessage = viewModel.errorMessage {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.brandSecondary)
                    
                    Text("Proses Terhenti")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelDark)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(Color.labelLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ButtonApp(title: "Coba Lagi", action: {
                        viewModel.resetAndRetry(url: urlToScrape, onComplete: { recipe in
                            onComplete?(recipe)
                        })
                    })
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        if let recipe = viewModel.recipe {
                            onComplete?(recipe)
                        } else {
                            dismiss()
                        }
                    }) {
                        Text(viewModel.recipe != nil ? "Lanjutkan Tanpa Rincian" : "Batal")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.brandPrimary)
                    }
                    .padding(.top, 8)
                }
            } else {
                // Loading state

                ProgressView()
                    .scaleEffect(2)
                    .tint(Color.brandPrimary)
                
                Text(viewModel.state.message)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.brandPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                Button(action: {
                    viewModel.cancel()
                    dismiss()
                }) {
                    Text("Batal")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelLight)
                }
//                .padding(.top, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            VStack {
                RadialGradientCircle(color: Color.ovalGreen.opacity(0.75), offset: -125, width: 600, height: 600)
                
                Spacer()
                
                RadialGradientCircle(color: Color.ovalGreen.opacity(0.75), offset: 125, width: 600, height: 600)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.start(url: urlToScrape, onComplete: { recipe in
                onComplete?(recipe)
            })
        }
        .translationTask(viewModel.configIdToEn) { session in
            await viewModel.translateToEnglish(session: session)
        }
        .translationTask(viewModel.configEnToId) { session in
            await viewModel.translateToIndonesian(session: session)
        }
    }
}

#Preview {
    NavigationStack {
        ImportLoadingView(urlToScrape: "https://cookpad.com/id/resep/example")
    }
}
