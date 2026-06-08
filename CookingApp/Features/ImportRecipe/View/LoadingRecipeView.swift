import SwiftUI

struct LoadingRecipeView: View {
    @State private var navigateToEdit = false
    var onSave: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2)
                .tint(Color.brandPrimary!)
            Text("Mengekstrak Resep...")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color.labelDark!)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceDefault.ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // Sembunyikan tombol back saat loading
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                navigateToEdit = true
            }
        }
        .navigationDestination(isPresented: $navigateToEdit) {
            EditDetailRecipeView(onSave: onSave)
                .navigationBarBackButtonHidden(true) // Sembunyikan back agar tidak kembali ke loading
        }
    }
}

#Preview {
    NavigationStack {
        LoadingRecipeView()
    }
}
