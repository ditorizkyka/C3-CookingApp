import SwiftUI
import TipKit

struct WebsitePreviewSheet: View {
    let urlString: String
    let onImport: () -> Void
    let onDismiss: () -> Void
    @State private var isLoading: Bool = false
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    
    let saveRecipeTip = ToolTip(tipTitle: "Siapkan Panduan Masak", tipSubtitle: "Simpan untuk menyusun resep ini menjadi langkah-langkah yang lebih mudah diikuti.", iconName: "square.and.arrow.down.on.square.fill", buttonTitle: "")
    
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
                                    onboardingStep = 3
                                }
                                onImport()
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .conditionalPopoverTip(onboardingStep == 2, tip: saveRecipeTip, arrowEdge: .bottom)
                   
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
                    .disabled(isLoading || onboardingStep == 2)
                }
            }
        }
        .tint(Color.brandPrimary)
        .interactiveDismissDisabled(onboardingStep == 2)
    }
}
