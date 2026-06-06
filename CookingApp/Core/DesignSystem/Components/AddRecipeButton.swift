import SwiftUI

struct AddRecipeButton: View {
    var isManual: Bool
    var titleButton: String
    var descriptionButton: String
    
    var body: some View {
        Button(action: {
            // Action tombol
        }) {
            // 1. Tambahkan alignment .leading pada VStack paling luar agar ikon dan teks rata kiri
            VStack(alignment: .leading, spacing: 10) {
                
                // Bagian Ikon
                if isManual {
                    Image(systemName: AppIcon.importRecipeIcon)
                        .font(.headline)
                        .frame(width: 45, height: 45)
                        .background(Color.labelLightest.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    Image(systemName: AppIcon.manualImportIcon)
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 45, height: 45)
                        .background(Color.labelLightest.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                // Bagian Teks
                VStack(alignment: .leading) { // Tambah sedikit spacing antar teks
                    Text(titleButton)
                        .font(.headline)
                        .bold()
                    
                    Text(descriptionButton)
                        .font(Font.subheadline)
                        .multilineTextAlignment(.leading)
                    
                }
 
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 148)
            .background(isManual ? Color.brandSecondary : Color.brandPrimary)
            .cornerRadius(Radius.card)
            .foregroundStyle((isManual ? Color.labelDark : Color.labelLightest) ?? .white)
        }
    }
}

#Preview {
    HStack() {
        AddRecipeButton(isManual: false, titleButton: "Import Resep", descriptionButton: "Tambahkan resep dari link website")
        AddRecipeButton(isManual: true, titleButton: "Tulis Resep", descriptionButton: "Buat dan simpan resepmu")
    }
    .padding()
}
