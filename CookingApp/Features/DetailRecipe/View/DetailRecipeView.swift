import SwiftUI

// MARK: - Halaman Utama
struct DetailRecipeView: View {
    
    @StateObject private var viewModel: DetailRecipeViewModel
    
    var recipeAssetImage: String? = nil
    var isFromImport: Bool = false
    
    @State private var showInstructionHelper: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    let startCookTip = ToolTip(tipTitle: "Mulai Simulasi Masak", tipSubtitle: "Mari lihat bagaimana aplikasi ini memandu instruksi resepmu tanpa perlu menyentuh layar.", iconName: "flame.fill", buttonTitle: "Lewati")
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    
    // MARK: - Initializers
    
    /// Initialize with a Recipe model (used for import flow and when passing a recipe directly)
    init(recipe: Recipe, isFromImport: Bool = false) {
        self._viewModel = StateObject(wrappedValue: DetailRecipeViewModel(recipe: recipe))
        self.isFromImport = isFromImport
    }
    
    /// Initialize with default dummy data (for previews and existing usage)
    init() {
        self._viewModel = StateObject(wrappedValue: DetailRecipeViewModel(recipe: Recipe.dummyRecipes[0]))
        self.isFromImport = false
    }
       
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Header (Image, Title, Button)
                VStack(alignment: .leading) {
                    
                    if viewModel.isEdited {
                        RecipeHeader(isEdited: viewModel.isEdited)
                    } else {
                        RecipeHeader(isEdited: viewModel.isEdited)
                        ButtonApp(title: "Mulai Masak", action: {
                            if onboardingStep == 3 {
                                onboardingStep = 4
                            }
                            showInstructionHelper = true
                        })
                        .padding(.bottom, 8)
                        .conditionalPopoverTip(onboardingStep == 3, tip: startCookTip, arrowEdge: .top)
                    }

                    
                    
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
//                // MARK: - Atribut Resep (Porsi & Waktu)
//                Section {
//                    HStack {
//                        Text("Jumlah Porsi")
//                            .foregroundColor(Color.labelDark!)
//                        Spacer()
//                        Text("\(recipe.portion) Orang")
//                            .foregroundColor(Color.labelLight!)
//                    }
//                    HStack {
//                        Text("Lama Memasak")
//                            .foregroundColor(Color.labelDark!)
//                        Spacer()
//                        Text("\(recipe.durationInMinutes) Menit")
//                            .foregroundColor(Color.labelLight!)
//                    }
//                }
                
                // MARK: - Bahan-bahan
                Section(header: Text("Bahan-bahan")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLight!)
                ) {
                    
                    if !viewModel.recipe.ingredients.isEmpty {
                        ForEach(viewModel.recipe.ingredients.indices, id: \.self) { index in
                            let ingredient = viewModel.recipe.ingredients[index]
                            
                            if ingredient.groupIngredients != nil {
                                // --- Group Header ---
                                if viewModel.isEdited {
                                    HStack {
                                        Button {
                                            viewModel.deleteIngredient(at: IndexSet(integer: index))
                                        } label: {
                                            Image(systemName: AppIcon.minusFill)
                                                .foregroundStyle(Color.actionDelete!)
                                        }
                                        TextField("Nama Grup", text: Binding(
                                            get: { viewModel.recipe.ingredients[index].name },
                                            set: { viewModel.recipe.ingredients[index].name = $0 }
                                        ))
                                        .font(.headline)
                                        .foregroundColor(Color.labelDark!)
                                        Spacer()
                                        Image(systemName: AppIcon.line3Horizontal)
                                            .foregroundStyle(Color.labelLight!)
                                    }
                                    .padding(.horizontal, 10)
                                    .listRowSeparator(.hidden)
                                } else {
                                    Text(ingredient.name)
                                        .font(.headline)
                                        .foregroundColor(Color.labelDark!)
                                        .padding(.top, 8)
                                        .padding(.bottom, 2)
                                        .listRowSeparator(.hidden)
                                }
                                
                                // --- Sub-ingredients ---
                                let subCount = ingredient.groupIngredients?.count ?? 0
                                ForEach(0..<subCount, id: \.self) { subIndex in
                                    if viewModel.isEdited {
                                        EditIngredientsRow(
                                            isBreakdown: true,
                                            ingredientsItemsName: Binding(
                                                get: { viewModel.recipe.ingredients[index].groupIngredients?[subIndex].name ?? "" },
                                                set: { viewModel.recipe.ingredients[index].groupIngredients?[subIndex].name = $0 }
                                            ),
                                            ingredientsItemsQty: Binding(
                                                get: { viewModel.recipe.ingredients[index].groupIngredients?[subIndex].quantity ?? "" },
                                                set: { viewModel.recipe.ingredients[index].groupIngredients?[subIndex].quantity = $0 }
                                            )
                                        )
                                    } else {
                                        let sub = ingredient.groupIngredients![subIndex]
                                        HStack(alignment: .center, spacing: 12) {
                                            Circle()
                                                .fill(Color.labelDark!)
                                                .frame(width: 3, height: 3)
                                            Text(sub.quantity).font(.body)
                                            Text(sub.name).font(.body)
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                            } else {
                                // --- Single ingredient ---
                                if viewModel.isEdited {
                                    EditIngredientsRow(
                                        isBreakdown: false,
                                        ingredientsItemsName: Binding(
                                            get: { viewModel.recipe.ingredients[index].name },
                                            set: { viewModel.recipe.ingredients[index].name = $0 }
                                        ),
                                        ingredientsItemsQty: Binding(
                                            get: { viewModel.recipe.ingredients[index].quantity },
                                            set: { viewModel.recipe.ingredients[index].quantity = $0 }
                                        )
                                    )
                                } else {
                                    HStack {
                                        Text(ingredient.quantity).font(.body)
                                        Text(ingredient.name).font(.body)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        
                        }
                    }
                    
                    if viewModel.isEdited {
                        ButtonAddIngredientsRow(isGroup: true)
                            .listRowBackground(Color.surfaceBrand)
                            
                        ButtonAddIngredientsRow(isGroup: false)
                            .listRowBackground(Color.surfaceBrand)
                    }
                    
                }
                
                // MARK: - Langkah-langkah
                Section(header: Text("Langkah-langkah")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLight!)
                ) {
                    if !viewModel.recipe.instructions.isEmpty {
                        ForEach(viewModel.recipe.instructions.indices, id: \.self) { index in
                            if viewModel.isEdited {
                                // Edit mode: use EditInstructionRow which handles
                                // the main step text + breakdown sub-steps internally
                                EditInstructionRow(
                                    instruction: Binding(
                                        get: { viewModel.recipe.instructions[index] },
                                        set: { viewModel.recipe.instructions[index] = $0 }
                                    )
                                )
                                .listRowSeparator(.hidden)
                            } else {
                                // View mode: use InstructionRowView which shows
                                // numbered step + expandable breakdown sub-steps
                                InstructionRowView(instruction: viewModel.recipe.instructions[index])
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                    }

                    if viewModel.isEdited {
                        // Add a new instruction step
                        Button {
                            let newInstruction = Instruction(
                                id: UUID(),
                                sequenceNumber: viewModel.recipe.instructions.count + 1,
                                text: "",
                                photoUrl: nil,
                                breakdownInstruction: []
                            )
                            withAnimation {
                                viewModel.recipe.instructions.append(newInstruction)
                            }
                        } label: {
                            HStack {
                                Image(systemName: AppIcon.plusFill)
                                    .foregroundStyle(Color.brandPrimary!)
                                Text("Tambah Langkah")
                                    .font(.body)
                                    .foregroundStyle(Color.brandPrimary!)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                        }
                        .listRowBackground(Color.surfaceBrand)
                    }
                }
                
                Section(
                ) {
                   if viewModel.isEdited {
                        TotalPortionRow(selectedPortion: $viewModel.recipe.portion)
                        TotalDurationRow(selectedDuration: $viewModel.recipe.durationInMinutes)
                   } else {
                       HStack {
                           Text("Jumlah Porsi")
                               .font(.body)
                               .foregroundStyle(Color.labelLight!)
                           
                           Spacer()
                           Text("\(viewModel.recipe.portion) Orang")
                       }
                       HStack {
                           Text("Lama Memasak")
                               .font(.body)
                               .foregroundStyle(Color.labelLight!)
                           
                           Spacer()
                           Text("\(viewModel.recipe.durationInMinutes) Menit")
                       }
                   }
                    
                }
                
                Section() {
                    if viewModel.isEdited {
                        ButtonApp(title: "Simpan") {
                            viewModel.isEdited.toggle()
                        }
                    }
                }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleEditMode()
                    } label: {
                        Text(viewModel.isEdited ? "Selesai" : "Ubah")
                            .font(.body)
                            .fontWeight(viewModel.isEdited ? .semibold : .regular)
                            .foregroundStyle(Color.brandPrimary!)
                    }
                }
            }
            .navigationDestination(isPresented: $showInstructionHelper) {
                InstructionHelperView(recipe: viewModel.recipe)
            }
        }
    }
    
    
    // MARK: - ViewBuilders untuk Bahan
    
    @ViewBuilder
    func RenderSingleIngredientItem(ingredient: Ingredient) -> some View {
        HStack {
            Text(ingredient.quantity)
                .font(.body)
            
            Text(ingredient.name)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func RenderIngredientGroupItems(items: [Ingredient]) -> some View {
        ForEach(items) { ingredient in
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(Color.labelDark!)
                    .frame(width: 3, height: 3)
                
                HStack {
                    Text(ingredient.quantity)
                        .font(.body)
                    
                    Text(ingredient.name)
                        .font(.body)
                }
                
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
                .font(.footnote)
                .foregroundColor(Color.labelDark!)
                .frame(width: 22, height: 22)
                .background(Color.brandSecondary)
                .clipShape(Circle())
                .padding(.leading, 30)
                .padding(.trailing, 10)
            
            Text(instruction.text)
                .font(.body)
                .foregroundColor(Color.labelDark!)
                .padding(.vertical, 16)
            
            Spacer()
            
            if !instruction.breakdownInstruction.isEmpty {
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle")
                        .font(.title2)
                        .foregroundColor(isExpanded ? Color.brandPrimary! : Color.labelLight)
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
            
            
            VStack(alignment: .leading, spacing: 14) {
                ForEach(instruction.breakdownInstruction) { subStep in
                    SubStepRow(subStep: subStep)
                }
            }
            .padding(.leading, 40)
            .padding(.trailing, 16)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private func SubStepRow(subStep: Instruction) -> some View {
        HStack(alignment: .center, spacing: 32) {
            Circle()
                .fill(Color.labelLight!)
                .frame(width: 3, height: 3)
            
            Text(subStep.text)
                .font(.subheadline)
                .foregroundStyle(Color.labelLight!)
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
