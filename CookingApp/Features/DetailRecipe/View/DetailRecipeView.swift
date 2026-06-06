import SwiftUI

// MARK: - Komponen Reusable Gambar (Tetap sama)
struct RecipeHeaderImage: View {
    var imageName: String?
    var height: CGFloat = 221
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        Group {
            if let name = imageName, !name.isEmpty {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                    Text("No Image")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Halaman Utama
struct DetailRecipeView: View {
    // Variabel state
    var recipeAssetImage: String? = nil
    
    // Menggunakan dummy data untuk resep
    var dummyData: Recipe = Recipe.dummyRecipes[0]
       
    var body: some View {
        NavigationStack {
            List {
                // ==========================================
                // SECTION 1: HEADER (Gambar, Judul, Tombol)
                // ==========================================
                VStack(alignment: .leading) {
                    RecipeHeaderImage(imageName: recipeAssetImage)
                    
                    Text(dummyData.title)
                        .lineLimit(2)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.vertical, 24)
                    
                    ButtonApp(title: "Mulai Masak", iconButton: "frying.pan", action: {
                        print("Mulai masak ditekan!")
                    })
                    .padding(.bottom, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                // ==========================================
                // SECTION 2: ATRIBUT RESEP (Porsi & Waktu)
                // ==========================================
                Section() {
                    HStack {
                        Text("Jumlah Porsi")
                        Spacer()
                        Text("\(dummyData.portion) Orang")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Lama Memasak")
                        Spacer()
                        Text("\(dummyData.durationInMinutes) Menit")
                            .foregroundColor(.secondary)
                    }
                }
                
                // ==========================================
                // SECTION 3: BAHAN - BAHAN
                // ==========================================
                // Kita buat satu Section besar dengan header "Bahan-bahan"
                Section(header: Text("Bahan-bahan").font(.title3).fontWeight(.semibold).foregroundColor(.primary)) {
                    
                    ForEach(dummyData.ingredientGroups) { group in
                        
                        // Jika ada nama grup (misal: "Bumbu Halus")
                        if let namaGrup = group.groupName, !namaGrup.isEmpty {
                            
                            // Gunakan Text biasa yang ditebalkan sebagai pembatas grup di dalam List
                            // Hindari menggunakan Section di dalam Section
                            Text(namaGrup)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                                .padding(.bottom, 2)
                                .listRowSeparator(.hidden) // Hilangkan garis atasnya
                            
                            RenderIngredientGroupItems(items: group.items)
                            
                        } else {
                            // Jika tidak ada nama grup (List biasa)
                            RenderIngredientItems(items: group.items)
                        }
                    }
                }
                
                // ==========================================
                // SECTION 4: LANGKAH - LANGKAH
                // ==========================================
                Section(header: Text("Langkah-langkah").font(.title3).fontWeight(.semibold).foregroundColor(.primary)) {
                    
                    ForEach(dummyData.instructions) { step in
                        // Memanggil struct terpisah agar isExpanded independen tiap baris
                        InstructionRowView(instruction: step)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - ViewBuilders untuk Bahan
    
    @ViewBuilder
    func RenderIngredientItems(items: [Ingredient]) -> some View {
        ForEach(items) { ingredient in
            Text("\(ingredient.quantity) \(ingredient.name)")
                .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    func RenderIngredientGroupItems(items: [Ingredient]) -> some View {
        ForEach(items) { ingredient in
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 5, height: 5)
                
                Text("\(ingredient.quantity) \(ingredient.name)")
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}


// MARK: - Struct Terpisah untuk Baris Instruksi (WAJIB TERPISAH)
// Mengapa? Karena setiap baris butuh status 'isExpanded' masing-masing.
struct InstructionRowView: View {
    let instruction: Instruction
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MainInstructionRow()
            
            if isExpanded && !instruction.breakdownInstruction.isEmpty {
                BreakdownSection()
            }
        }
    }
    
    @ViewBuilder
    private func MainInstructionRow() -> some View {
        // 1. UBAH ALIGNMENT MENJADI .center
        HStack(alignment: .center, spacing: 12) {
            
            Text("\(instruction.sequenceNumber)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
//                .frame(width: 40, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing,10)
//                .background(.red)
                // HAPUS padding(.top, 12) di sini!
            
            
            Text(instruction.text)
                .font(.body)
                .foregroundColor(.primary)
                // Teks inilah yang menentukan total tinggi baris ini
                .padding(.vertical, 16)
            
            Spacer()
            
            if !instruction.breakdownInstruction.isEmpty {
                Divider()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(isExpanded ? Color.accentColor : Color.gray.opacity(0.4))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.trailing, 16)
                        // HAPUS padding(.top, 12) di sini juga!
                }
                .buttonStyle(.plain)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
//        .background(.yellow)
    }
    
    @ViewBuilder
    private func BreakdownSection() -> some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.leading, 76)
            
            VStack(alignment: .leading, spacing: 14) {
                ForEach(instruction.breakdownInstruction) { subStep in
                    SubStepRow(subStep: subStep)
                }
            }
            .padding(.leading, 50)
            .padding(.trailing, 16)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private func SubStepRow(subStep: Instruction) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 6, height: 6)
            
            Text(subStep.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Garis Pemisah Vertikal
struct SeparatorView: View {
    var body: some View {
        Rectangle()
            .fill(Color(UIColor.separator))
            .frame(width: 1)
            .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct DetailRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        DetailRecipeView()
    }
}
