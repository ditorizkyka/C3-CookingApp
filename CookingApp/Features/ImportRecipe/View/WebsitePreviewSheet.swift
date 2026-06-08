import SwiftUI

struct WebsitePreviewSheet: View {
    let urlString: String
    let onImport: () -> Void
    let onDismiss: () -> Void
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                    
                    ButtonApp(title: "Simpan Resep", type: .primary) {
                        isLoading = true
                        Task {
//                            // Tahan selama 4 detik
//                            try? await Task.sleep(nanoseconds: 4_000_000_000)
                            
                            await MainActor.run {
//                                isLoading = false
                                onImport()
                            }
                        }
                    }
                    .padding(.bottom, 16)
                   
                }
                .padding(.horizontal, 16)
                
//                if isLoading {
//                    LoadingView(text: "Memproses...")
//                }
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
    }
}
