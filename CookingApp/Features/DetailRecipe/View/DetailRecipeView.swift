import SwiftUI
import SwiftData
import TipKit
import UniformTypeIdentifiers

// MARK: - Halaman Utama
struct DetailRecipeView: View {
    
    @StateObject private var viewModel: DetailRecipeViewModel
    @State var isFromImport: Bool
    
    var recipeAssetImage: String? = nil
    var onDismiss: (() -> Void)? = nil
    
    @State private var showInstructionHelper: Bool = false
    @State private var showImportConfirmation: Bool = false
    @State private var showEditBackConfirmation: Bool = false
    @State private var showRecipeActions: Bool = false
    @State private var showDeleteRecipeConfirmation: Bool = false
    @State private var draggingIngredientID: UUID? = nil
    @State private var draggingInstructionID: UUID? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.popToRoot) private var popToRoot
    
    @AppStorage("onboardingStep") private var onboardingStep = 0
    @State private var isTipReady = false
    
    // MARK: - Initializers
    
    /// Initialize with a Recipe model (used for import flow and when passing a recipe directly)
    init(recipe: Recipe, isFromImport: Bool = false, onDismiss: (() -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: DetailRecipeViewModel(recipe: recipe, isFromImport: isFromImport))
        self._isFromImport = State(initialValue: isFromImport)
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        List {
            // MARK: - Header (Image, Title, Button)
            Section {
                VStack(alignment: .leading) {
                    
                    if viewModel.isEdited {
                        RecipeHeader(viewModel: viewModel, isEdited: viewModel.isEdited)
                    } else {
                        RecipeHeader(viewModel: viewModel, isEdited: viewModel.isEdited)
                        Text(viewModel.recipe.title)
                        
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .font(.title)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 48)
                    }
                    
                    
                    
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            
            Section {
                if !viewModel.isEdited {
                    ButtonApp(title: "Mulai Masak", action: {
                        if onboardingStep == 3 {
                            updateOnboarding(to: 4)
                        }
                        showInstructionHelper = true
                    })
                    .padding(.bottom, 8)
                    .conditionalTip(isTipReady, tip: StartCookTip(), arrowEdge: .top) { action in
                        if onboardingStep == 3 {
                            updateOnboarding(to: 4)
                        }
                        StartCookTip().invalidate(reason: .actionPerformed)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            handleDismiss()
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            
            
            
            
            
            // MARK: - Bahan-bahan
            ingredientsSection
            
            // MARK: - Langkah-langkah
            instructionsSection
            
            Section(
            ) {
                if viewModel.isEdited {
                    TotalPortionRow(selectedPortion: $viewModel.recipe.portion)
                    TotalDurationRow(selectedDuration: $viewModel.recipe.durationInMinutes)
                    RecipeCategoryRow(selectedCategory: $viewModel.recipe.category)
                } else {
                    HStack {
                        Text("Jumlah Porsi")
                            .font(.body)
                            .foregroundStyle(Color.labelLight)
                        
                        Spacer()
                        if viewModel.recipe.portion == 0 {
                            Text("Tidak tahu")
                        } else if viewModel.recipe.portion == 11 {
                            Text("Lebih dari 10 Orang")
                        } else {
                            Text("\(viewModel.recipe.portion) Orang")
                        }
                    }
                    HStack {
                        Text("Lama Memasak")
                            .font(.body)
                            .foregroundStyle(Color.labelLight)
                        
                        Spacer()
                        if viewModel.recipe.durationInMinutes == 121 {
                            Text("> 120 Menit")
                        } else {
                            Text("\(viewModel.recipe.durationInMinutes) Menit")
                        }
                    }
                    HStack {
                        Text("Kategori")
                            .font(.body)
                            .foregroundStyle(Color.labelLight)
                        
                        Spacer()
                        Text("\(viewModel.recipe.category.icon) \(viewModel.recipe.category.rawValue)")
                    }
                }
                
            }
            
            Section() {
                if viewModel.isEdited {
                    ButtonApp(title: "Simpan") {
                        if viewModel.commitEditing() {
                            if !isFromImport {
                                do { try modelContext.save() } catch { print("Save error: \(error)") }
                            } else {
                                modelContext.insert(viewModel.recipe)
                                do { try modelContext.save() } catch { print("Insert save error: \(error)") }
                                isFromImport = false
                                print("✅ Saved imported recipe from ButtonApp")
                            }
                        }
                    }
                } 
////                    Button(role: .destructive) {
////                        showDeleteRecipeConfirmation = true
////                    } label: {
////                        Text("Hapus")
////                            .font(.headline) // Membuat teks lebih tebal
////                            .frame(maxWidth: .infinity) // Membuat background membentang penuh (Infinity)
////                            .padding(.vertical, 8) // [ADJUSTABLE] Padding dalam: Mengatur ketebalan/tinggi tombol
////                    }
////                    .buttonStyle(.borderedProminent) // Gaya 2: Background solid otomatis
////                    //                            .padding(.hori)
//                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            
        }
        .listStyle(.insetGrouped)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isFromImport || viewModel.isEdited)
        .toolbar {
            // Keyboard dismiss button
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Selesai") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.brandPrimary)
            }
            
            // Back button — intercepted while editing (confirm save/discard) or
            // during the import flow (confirm keep/discard).
            if isFromImport || viewModel.isEdited {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if viewModel.isEdited {
                            showEditBackConfirmation = true
                        } else {
                            print("✅ User chose to save the imported recipe")
                            handleDismiss()
                            //                            showImportConfirmation = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isEdited {
                    Button {
                        if viewModel.commitEditing() {
                            if !isFromImport {
                                do { try modelContext.save() } catch { print("Save error: \(error)") }
                            } else {
                                modelContext.insert(viewModel.recipe)
                                do { try modelContext.save() } catch { print("Insert save error: \(error)") }
                                isFromImport = false
                                print("✅ User chose to save the imported recipe from Checkmark")
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.brandPrimary)
                    }
                } else {
                    Button {
                        viewModel.beginEditing()
                    }label : {
                        Text("Ubah")
                    }
                    
                    //                    Menu("More", systemImage: "ellipsis") {
                    //                        Button("Ubah Resep", systemImage: "pencil") {
                    //                            viewModel.beginEditing()
                    //                        }
                    //                        Button("Hapus Resep", systemImage: "trash", role: .destructive) {
                    //                            showDeleteRecipeConfirmation = true
                    //                        }
                    //                    }
                }
            }
        }
        .navigationDestination(isPresented: $showInstructionHelper) {
            InstructionHelperView(recipe: viewModel.recipe, onGoToHome: {
                handleDismiss()
            })
        }
        // Back navigation while editing — confirm save or discard.
        .alert("Simpan Perubahan?", isPresented: $showEditBackConfirmation) {
            Button("Simpan", role: .none) {
                // Commit; if validation fails it surfaces its own alert and stays.
                if viewModel.commitEditing() {
                    if isFromImport {
                        modelContext.insert(viewModel.recipe)
                        do { try modelContext.save() } catch { print("Insert save error: \(error)") }
                        isFromImport = false
                        handleDismiss()
                    } else {
                        do { try modelContext.save() } catch { print("Save error: \(error)") }
                        handleDismiss()
                    }
                }
            }
            Button("Buang", role: .destructive) {
                viewModel.cancelEditing()
                if isFromImport {
                    handleDismiss()
                } else {
                    handleDismiss()
                }
            }
            Button("Batal", role: .cancel) { }
        } message: {
            Text("Kamu sedang mengubah resep. Simpan perubahan sebelum keluar?")
        }
        // Empty-field validation feedback.
        .alert("Lengkapi Resep", isPresented: $viewModel.showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.validationMessage)
        }
        // Confirm before permanently deleting the recipe.
        .alert("Hapus Resep?", isPresented: $showDeleteRecipeConfirmation) {
            Button("Hapus", role: .destructive) {
                modelContext.delete(viewModel.recipe)
                handleDismiss()
            }
            Button("Batal", role: .cancel) { }
        } message: {
            Text("Resep ini akan dihapus secara permanen.")
        }
        .onAppear {
            guard onboardingStep == 3 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTipReady = true
            }
        }
        .onDisappear {
            isTipReady = false
        }
    }
    
    private func handleDismiss() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }
    
    // MARK: - Sections (extracted to keep the body type-checkable)
    
    @ViewBuilder
    private var ingredientsSection: some View {
        Section(header: Text("Bahan-bahan")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(Color.labelLight)
        ) {
            if !viewModel.recipe.ingredients.isEmpty {
                ForEach(viewModel.recipe.ingredients) { ingredient in
                    if viewModel.recipe.ingredients.contains(where: { $0.id == ingredient.id }) {
                        Group {
                            if ingredient.isGroup {
                                groupIngredientRows(ingredient)
                            } else {
                                singleIngredientRow(ingredient)
                                
                            }
                        }
                    }
                }
            }
            
            if viewModel.isEdited {
                // Bug 2 Fix: Tambah Bahan
                ButtonAddIngredientsRow(isGroup: false) {
                    withAnimation { viewModel.addIngredient() }
                }
                .listRowBackground(Color.surfaceBrand)
                
                // Bug 2 Fix: Tambah Grup
                ButtonAddIngredientsRow(isGroup: true) {
                    withAnimation { viewModel.addIngredientGroup() }
                }
                .listRowBackground(Color.surfaceBrand)
            }
        }
    }
    
    @ViewBuilder
    private func groupIngredientRows(_ ingredient: Ingredient) -> some View {
        // --- Group Header ---
        if viewModel.isEdited {
            HStack {
                DeleteConfirmButton {
                    viewModel.deleteIngredient(ingredient)
                }
                TextField("Nama Grup", text: stringBinding(ingredient, \.name))
                    .font(.headline)
                    .foregroundColor(Color.labelDark)
                Spacer()
                
            }
            .padding(.horizontal, 10)
            .listRowSeparator(.hidden)
            .onDrop(of: [.text], delegate: ReorderDropDelegate(
                item: ingredient,
                items: ingredientsBinding,
                draggingID: $draggingIngredientID
            ))
        } else {
            Text(ingredient.name)
                .font(.headline)
                .foregroundColor(Color.labelDark)
                .padding(.top, 8)
                .padding(.bottom, 2)
                .listRowSeparator(.hidden)
        }
        
        // --- Sub-ingredients ---
        ForEach(ingredient.groupIngredients ?? []) { sub in
            if viewModel.isEdited {
                EditIngredientsRow(
                    isBreakdown: true,
                    ingredientsItemsName: stringBinding(sub, \.name),
                    ingredientsItemsQty: stringBinding(sub, \.quantity),
                    onDelete: {
                        viewModel.deleteSubIngredient(from: ingredient, sub: sub)
                    }
                )
            } else {
                IngredientRowView(quantity: sub.quantity, name: sub.name, isSubItem: true)
            }
        }
        
        // Bug 3 Fix: Tambah Anggota Grup
        if viewModel.isEdited {
            Button {
                withAnimation {
                    if ingredient.groupIngredients == nil {
                        ingredient.groupIngredients = []
                    }
                    ingredient.groupIngredients?.append(Ingredient(quantity: "", name: ""))
                }
            } label: {
                HStack {
                    Image(systemName: AppIcon.plusFill)
                        .foregroundStyle(Color.brandPrimary)
                    Text("Tambah Anggota")
                        .font(.body)
                        .foregroundStyle(Color.brandPrimary)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.leading,25)
            }
            
        }
    }
    
    @ViewBuilder
    private func singleIngredientRow(_ ingredient: Ingredient) -> some View {
        if viewModel.isEdited {
            EditIngredientsRow(
                isBreakdown: false,
                ingredientsItemsName: stringBinding(ingredient, \.name),
                ingredientsItemsQty: stringBinding(ingredient, \.quantity),
                onDelete: {
                    viewModel.deleteIngredient(ingredient)
                },
            )
            
        } else {
            IngredientRowView(quantity: ingredient.quantity, name: ingredient.name, isSubItem: false)
        }
    }
    
    @ViewBuilder
    private var instructionsSection: some View {
        Section(header: Text("Langkah-langkah")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(Color.labelLight)
        ) {
            let sortedInstructions = viewModel.recipe.instructions.sorted { $0.sequenceNumber < $1.sequenceNumber }
            if !sortedInstructions.isEmpty {
                ForEach(Array(sortedInstructions.enumerated()), id: \.element.id) { index, instructionItem in
                    if viewModel.isEdited {
                        EditInstructionRow(
                            instruction: instructionItem,
                            displayNumber: index + 1,
                            onDelete: {
                                viewModel.deleteInstruction(instructionItem)
                            },
                        )
                        .listRowSeparator(.hidden)
                    } else {
                        InstructionRowView(
                            instruction: instructionItem,
                            displayNumber: index + 1
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
            
            if viewModel.isEdited {
                Button {
                    withAnimation { viewModel.addInstruction() }
                } label: {
                    HStack {
                        Image(systemName: AppIcon.plusFill)
                            .foregroundStyle(Color.brandPrimary)
                        Text("Tambah Langkah")
                            .font(.body)
                            .foregroundStyle(Color.brandPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                }
                .listRowBackground(Color.surfaceBrand)
            }
        }
    }
    
    // MARK: - Edit Helpers
    
    /// Live bindings to the recipe's relationship arrays (used by the reorder drop delegate).
    private var ingredientsBinding: Binding<[Ingredient]> {
        Binding(
            get: { viewModel.recipe.ingredients },
            set: { viewModel.recipe.ingredients = $0 }
        )
    }
    
    private var instructionsBinding: Binding<[Instruction]> {
        Binding(
            get: { viewModel.recipe.instructions },
            set: { viewModel.recipe.instructions = $0 }
        )
    }
    
    /// Build a `Binding<String>` from a model object + key path. The binding captures
    /// the object reference (a class), so it remains valid regardless of array index.
    private func stringBinding<Object: AnyObject>(
        _ object: Object,
        _ keyPath: ReferenceWritableKeyPath<Object, String>
    ) -> Binding<String> {
        Binding(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
    
    
    // MARK: - ViewBuilders untuk Bahan
    
    @ViewBuilder
    func RenderSingleIngredientItem(ingredient: Ingredient) -> some View {
        HStack {
            if !ingredient.quantity.isEmpty {
                Text(ingredient.quantity)
                    .font(.body)
                    .foregroundColor(Color.labelDark)
            }
            
            Text(ingredient.name)
                .font(.body)
        }
        //        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func RenderIngredientGroupItems(items: [Ingredient]) -> some View {
        ForEach(items) { ingredient in
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(Color.labelDark)
                    .frame(width: 3, height: 3)
                
                HStack {
                    if !ingredient.quantity.isEmpty {
                        Text(ingredient.quantity)
                            .font(.body)
                            .foregroundColor(Color.labelDark)
                    }
                    
                    Text(ingredient.name)
                        .font(.body)
                }
                
                Spacer()
            }
            //            .padding(.vertical, 4)
        }
    }
}


// MARK: - Styled Ingredient Row
struct IngredientRowView: View {
    let quantity: String
    let name: String
    let isSubItem: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Bullet dot for sub-items
            if isSubItem {
                Circle()
                    .fill(Color.labelLight)
                    .frame(width: 4, height: 4)
            }
            
            // Quantity pill badge
            if !quantity.isEmpty {
                Text(quantity)
                    .font(.body)
                    .foregroundColor(Color.labelDark)
                
            }
            
            // Ingredient name
            Text(name)
                .font(.body)
                .foregroundColor(Color.labelDark)
            
            Spacer()
        }
        //        .padding(.vertical, 5)
        .padding(.leading, isSubItem ? 8 : 0)
    }
}

// MARK: - Struct Terpisah untuk Baris Instruksi
struct InstructionRowView: View {
    let instruction: Instruction
    /// Position-based number so steps read 1, 2, 3 … even after edits/deletes.
    var displayNumber: Int
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
            
            Text("\(displayNumber)")
                .font(.footnote)
                .foregroundColor(Color.labelDark)
                .frame(width: 22, height: 22)
                .background(Color.brandSecondary)
                .clipShape(Circle())
                .padding(.leading, 30)
                .padding(.trailing, 10)
            
            Text(instruction.text)
                .font(.body)
                .foregroundColor(Color.labelDark)
                .padding(.vertical, 16)
            
            Spacer()
            
            if !instruction.breakdownInstruction.isEmpty {
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.down.circle")
                        .font(.title2)
                        .foregroundColor(isExpanded ? Color.brandPrimary : Color.labelLight)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
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
                let sortedBreakdowns = instruction.breakdownInstruction.sorted { $0.sequenceNumber < $1.sequenceNumber }
                ForEach(sortedBreakdowns) { subStep in
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
                .fill(Color.labelLight)
                .frame(width: 3, height: 3)
            
            Text(subStep.text)
                .font(.subheadline)
                .foregroundStyle(Color.labelLight)
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
#Preview {
    let dummyRecipe = Recipe(
        title: "Nasi Goreng Spesial",
        portion: 2,
        durationInMinutes: 30,
        ingredients: [
            Ingredient(quantity: "2 piring", name: "Nasi Putih"),
            Ingredient(quantity: "3 siung", name: "Bawang Merah"),
            Ingredient(quantity: "2 siung", name: "Bawang Putih"),
            Ingredient(quantity: "1 butir", name: "Telur", groupIngredients: [
                Ingredient(quantity: "secukupnya", name: "Garam"),
                Ingredient(quantity: "secukupnya", name: "Merica")
            ])
        ],
        instructions: [
            Instruction(sequenceNumber: 1, text: "Haluskan bawang merah dan bawang putih."),
            Instruction(sequenceNumber: 2, text: "Panaskan minyak, orak-arik telur."),
            Instruction(sequenceNumber: 3, text: "Masukkan bumbu halus, tumis hingga harum.", breakdownInstruction: [
                Instruction(sequenceNumber: 1, text: "Gunakan api sedang."),
                Instruction(sequenceNumber: 2, text: "Aduk terus agar tidak gosong.")
            ]),
            Instruction(sequenceNumber: 4, text: "Masukkan nasi, kecap, garam, dan merica. Aduk rata.")
        ]
    )
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    container.mainContext.insert(dummyRecipe)
    
    return NavigationStack {
        DetailRecipeView(recipe: dummyRecipe)
    }
    .modelContainer(container)
}
