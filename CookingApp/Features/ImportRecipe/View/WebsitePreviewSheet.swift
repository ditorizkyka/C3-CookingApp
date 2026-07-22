import SwiftUI
import TipKit

struct WebsitePreviewSheet: View {
    let urlString: String
    let onImport: () -> Void
    let onDismiss: () -> Void
    @State private var isLoading: Bool = false
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    if let url = URL(string: urlString) {
                        WebView(url: url)
                            .edgesIgnoringSafeArea(.bottom)
                    } else {
                        Text("Invalid URL")
                            .font(.body)
                            .foregroundColor(Color.actionDelete)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    ButtonApp(title: "Simpan Resep", type: .primary) {
                        
                        Task {
                            await MainActor.run {
                                if onboardingStep == 2 {
                                    updateOnboarding(to: 3)
                                }
                                onImport()
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .conditionalTip(onboardingStep == 2, tip: SaveRecipeTip(), arrowEdge: .bottom)
                   
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .disabled(isLoading)
                }
            }
        }
        .tint(Color.brandPrimary)
    }
}
