import SwiftUI

// MARK: - Komponen Reusable Gambar
struct RecipeHeaderImage: View {
    var imageName: String?
    var height: CGFloat = 221
    
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
                .foregroundColor(Color.labelLight!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.surfaceDefault!)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }
}

// MARK: - Halaman Utama
struct DetailRecipeView: View {
    var recipeAssetImage: String? = nil
    var recipe: Recipe = Recipe.dummyRecipes[0]
       
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Header (Image, Title, Button)
                VStack(alignment: .leading) {
                    RecipeHeaderImage(imageName: recipeAssetImage)
                    
                    Text(recipe.title)
                        .lineLimit(2)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.labelDark!)
                        .padding(.vertical, 24)
                    
                    ButtonApp(title: "Mulai Masak", iconButton: AppIcon.fryingPan, action: {
                        print("Mulai masak ditekan!")
                    })
                    .padding(.bottom, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                // MARK: - Atribut Resep (Porsi & Waktu)
                Section {
                    HStack {
                        Text("Jumlah Porsi")
                            .foregroundColor(Color.labelDark!)
                        Spacer()
                        Text("\(recipe.portion) Orang")
                            .foregroundColor(Color.labelLight!)
                    }
                    HStack {
                        Text("Lama Memasak")
                            .foregroundColor(Color.labelDark!)
                        Spacer()
                        Text("\(recipe.durationInMinutes) Menit")
                            .foregroundColor(Color.labelLight!)
                    }
                }
                
                // MARK: - Bahan-bahan
                Section(header: Text("Bahan-bahan")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelDark!)
                ) {
                    ForEach(recipe.ingredients) { ingredient in
                        if let subIngredients = ingredient.groupIngredients {
                            
                            Text(ingredient.name)
                                .font(.headline)
                                .foregroundColor(Color.labelDark!)
                                .padding(.top, 8)
                                .padding(.bottom, 2)
                                .listRowSeparator(.hidden)
                            
                            RenderIngredientGroupItems(items: subIngredients)
                            
                        } else {
                            RenderSingleIngredientItem(ingredient: ingredient)
                        }
                    }
                }
                
                // MARK: - Langkah-langkah
                Section(header: Text("Langkah-langkah")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelDark!)
                ) {
                    ForEach(recipe.instructions) { step in
                        InstructionRowView(instruction: step)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                
                // MARK: - Tips
                if let tips = recipe.tips, !tips.isEmpty {
                    Section(header: Text("Tips")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelDark!)
                    ) {
                        Text(tips)
                            .font(.body)
                            .foregroundColor(Color.labelLight!)
                            .padding(.vertical, 4)
                    }
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditDetailRecipeView(editRecipeData: recipe)) {
                        Text("Edit")
                            .foregroundColor(Color.brandPrimary!)
                    }
                }
            }
        }
    }
    
    // MARK: - ViewBuilders untuk Bahan
    
    @ViewBuilder
    func RenderSingleIngredientItem(ingredient: Ingredient) -> some View {
        HStack {
            Text(ingredient.quantity)
                .foregroundColor(Color.labelLight!)
            Text(ingredient.name)
                .foregroundColor(Color.labelDark!)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func RenderIngredientGroupItems(items: [Ingredient]) -> some View {
        ForEach(items) { ingredient in
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(Color.labelLight!.opacity(0.4))
                    .frame(width: 5, height: 5)
                
                Text(ingredient.quantity)
                    .foregroundColor(Color.labelLight!)
                
                Text(ingredient.name)
                    .foregroundColor(Color.labelDark!)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}


// MARK: - Struct Terpisah untuk Baris Instruksi
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
        HStack(alignment: .center, spacing: 12) {
            
            Text("\(instruction.sequenceNumber)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.labelDark!)
                .padding(.leading, 20)
                .padding(.trailing, 10)
            
            Text(instruction.text)
                .font(.body)
                .foregroundColor(Color.labelDark!)
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
                        .foregroundColor(isExpanded ? Color.brandPrimary! : Color.labelLight!.opacity(0.4))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.trailing, 16)
                }
                .buttonStyle(.plain)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
                .fill(Color.labelLight!.opacity(0.3))
                .frame(width: 6, height: 6)
            
            Text(subStep.text)
                .font(.subheadline)
                .foregroundColor(Color.labelLight!)
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
