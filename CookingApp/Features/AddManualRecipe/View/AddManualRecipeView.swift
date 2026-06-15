//
//  AddManualRecipeView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct AddManualRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var recipeTitle: String = ""
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: [Instruction] = []
    @State private var draggingIngredientID: UUID? = nil
    @State private var draggingInstructionID: UUID? = nil
    @State private var portion: Int = 1
    @State private var durationInMinutes: Int = 10
    @State private var coverImageData: Data? = nil
    
    // Photo picker
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false
    
    // Alert
    @State private var showDiscardAlert = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    // Breakdown process
    @State private var navigateToBreakdown = false
    @State private var createdRecipe: Recipe?
    
    var onManualComplete: ((Recipe) -> Void)? = nil
    
    var body: some View {
        List {
            // MARK: - Header (Cover Image + Title)
            VStack(spacing: 16) {
                // Cover image
                Group {
                    if let data = coverImageData, let uiImage = UIImage(data: data) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 221)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                            
                            Button {
                                withAnimation { coverImageData = nil }
                            } label: {
                                Image(systemName: AppIcon.minusFill)
                                    .font(.title2)
                                    .foregroundColor(Color.actionDelete!)
                                    .background(Color.surfaceElevated!)
                                    .clipShape(Circle())
                            }
                            .offset(x: 10, y: -10)
                        }
                        .onTapGesture { showPhotoPicker = true }
                    } else {
                        Button { showPhotoPicker = true } label: {
                            VStack(spacing: 12) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color.labelLight!)
                                    
                                    Image(systemName: AppIcon.plusFill)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.labelLight!)
                                        .background(Color.surfaceElevated!)
                                        .clipShape(Circle())
                                        .offset(x: 4, y: 4)
                                }
                                
                                Text("Tambah Foto")
                                    .font(.callout)
                                    .foregroundColor(Color.labelLight!)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 221)
                            .background(Color.surfaceElevated!)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.small)
                                    .stroke(Color.labelLight!, style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Title text field
                TextField("Nama Resep", text: $recipeTitle)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .font(.title)
                    .background(Color.surfaceElevated)
                    .cornerRadius(Radius.infinity)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            
            // MARK: - Bahan-bahan
            ingredientsSection

            // MARK: - Langkah-langkah
            instructionsSection

            // MARK: - Porsi & Durasi
            Section {
                TotalPortionRow(selectedPortion: $portion)
                TotalDurationRow(selectedDuration: $durationInMinutes)
            }
            
            // MARK: - Simpan
            ButtonApp(title: "Simpan", action: { saveRecipe() })
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            
        }
        .listStyle(.insetGrouped)
        .background(Color.surfaceDefault)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // If user has entered any data, show discard alert
                    if hasUnsavedData {
                        showDiscardAlert = true
                    } else {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(Color.brandPrimary!)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Tulis Resep")
                    .font(.headline)
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    coverImageData = data
                }
            }
        }
        .alert("Buang Perubahan?", isPresented: $showDiscardAlert) {
            Button("Buang", role: .destructive) {
                dismiss()
            }
            Button("Lanjut Edit", role: .cancel) { }
        } message: {
            Text("Resep yang belum disimpan akan hilang.")
        }
        .alert("Validasi", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .navigationDestination(isPresented: $navigateToBreakdown) {
            if let recipe = createdRecipe {
                BreakdownLoadingView(
                    recipe: recipe,
                    onBreakdownComplete: onManualComplete,
                    onError: { _ in
                        dismiss()
                    }
                )
            }
        }
    }

    // MARK: - Sections (extracted to keep the body type-checkable)

    @ViewBuilder
    private var ingredientsSection: some View {
        Section(header: Text("Bahan-bahan")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(Color.labelLight!)
        ) {
            // Iterate the model objects (not indices) so deletes by id never
            // crash with "Index out of range".
            ForEach(ingredients) { ingredient in
                // Use `isGroup` (non-nil AND non-empty): a single ingredient added via
                // "Tambah Bahan" must never be rendered as a group, even if SwiftData
                // materializes its optional `groupIngredients` as an empty array.
                if ingredient.isGroup {
                    GroupedIngredientSectionView(ingredient: ingredient) {
                        withAnimation { ingredients.removeAll { $0.id == ingredient.id } }
                    }
                } else {
                    SingleIngredientSectionView(
                        ingredient: ingredient,
                        onDelete: {
                            withAnimation { ingredients.removeAll { $0.id == ingredient.id } }
                        },
                        onDrag: {
                            draggingIngredientID = ingredient.id
                            return NSItemProvider(object: ingredient.id.uuidString as NSString)
                        }
                    )
                    .onDrop(of: [.text], delegate: ReorderDropDelegate(
                        item: ingredient,
                        items: $ingredients,
                        draggingID: $draggingIngredientID
                    ))
                }
            }

            // Add single ingredient — appends one plain editable row.
            ButtonAddIngredientsRow(isGroup: false) {
                let newIngredient = Ingredient(quantity: "", name: "")
                withAnimation { ingredients.append(newIngredient) }
            }
            .listRowBackground(Color.surfaceBrand)

            // Add a group — a named section with its own add-ingredient button.
            ButtonAddIngredientsRow(isGroup: true) {
                let group = Ingredient(
                    quantity: "",
                    name: "",
                    groupIngredients: [Ingredient(quantity: "", name: "")]
                )
                withAnimation { ingredients.append(group) }
            }
            .listRowBackground(Color.surfaceBrand)
        }
    }

    @ViewBuilder
    private var instructionsSection: some View {
        Section(header: Text("Langkah")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(Color.labelLight!)
        ) {
            // Iterate the objects directly (stable identity) — the enumerated form
            // breaks live drag-reordering. Number is computed from current position.
            ForEach(instructions) { instruction in
                EditInstructionRow(
                    instruction: instruction,
                    displayNumber: (instructions.firstIndex(where: { $0.id == instruction.id }) ?? 0) + 1,
                    onDelete: {
                        withAnimation { instructions.removeAll { $0.id == instruction.id } }
                    },
                    onDrag: {
                        draggingInstructionID = instruction.id
                        return NSItemProvider(object: instruction.id.uuidString as NSString)
                    },
                    allowBreakdown: false
                )
                .listRowSeparator(.hidden)
                .onDrop(of: [.text], delegate: ReorderDropDelegate(
                    item: instruction,
                    items: $instructions,
                    draggingID: $draggingInstructionID,
                    onComplete: { renumberInstructions() }
                ))
            }

            ButtonAddInstructions {
                let newInstruction = Instruction(
                    sequenceNumber: instructions.count + 1,
                    text: "",
                    breakdownInstruction: []
                )
                withAnimation { instructions.append(newInstruction) }
            }
            .listRowBackground(Color.surfaceBrand)
        }
    }

    // MARK: - Helpers
    
    /// Check if user has entered any data worth saving
    private var hasUnsavedData: Bool {
        !recipeTitle.isEmpty || !ingredients.isEmpty || !instructions.isEmpty || coverImageData != nil
    }
    
    /// Keep step numbers aligned with their visual order after a reorder.
    private func renumberInstructions() {
        for (i, ins) in instructions.enumerated() { ins.sequenceNumber = i + 1 }
    }

    /// Validate and save the recipe to SwiftData
    private func saveRecipe() {
        // Every field must be filled in before saving.
        if let message = RecipeValidator.validate(
            title: recipeTitle,
            ingredients: ingredients,
            instructions: instructions
        ) {
            validationMessage = message
            showValidationAlert = true
            return
        }

        // Re-number instructions
        for (i, _) in instructions.enumerated() {
            instructions[i].sequenceNumber = i + 1
        }
        
        // Create the recipe
        let recipe = Recipe(
            title: recipeTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            author: nil,
            coverImageUrl: nil,
            coverImageData: coverImageData,
            portion: portion,
            durationInMinutes: durationInMinutes,
            ingredients: ingredients,
            instructions: instructions
        )
        
        print("✅ Manual Recipe Draft created: \"\(recipe.title)\" with \(ingredients.count) ingredients, \(instructions.count) instructions")
        
        // Navigate to Breakdown process
        createdRecipe = recipe
        navigateToBreakdown = true
    }
}

struct SingleIngredientSectionView: View {
    @Bindable var ingredient: Ingredient
    var onDelete: () -> Void
    var onDrag: (() -> NSItemProvider)? = nil

    var body: some View {
        EditIngredientsRow(
            isBreakdown: false,
            ingredientsItemsName: $ingredient.name,
            ingredientsItemsQty: $ingredient.quantity,
            onDelete: onDelete,
            onDrag: onDrag
        )
    }
}

struct GroupedIngredientSectionView: View {
    @Bindable var ingredient: Ingredient
    var onDeleteGroup: () -> Void

    var body: some View {
        if let groupIngredients = ingredient.groupIngredients {
            // --- Group Header ---
            HStack {
                DeleteConfirmButton {
                    onDeleteGroup()
                }

                TextField("Nama Grup", text: $ingredient.name)
                .font(.headline)
                .foregroundColor(Color.labelDark!)

                Spacer()

                Image(systemName: AppIcon.line3Horizontal)
                    .foregroundStyle(Color.labelLight!)
            }
            .padding(.horizontal, 10)
            .listRowSeparator(.hidden)

            // --- Sub-ingredients ---
            ForEach(groupIngredients) { sub in
                EditIngredientsRow(
                    isBreakdown: true,
                    ingredientsItemsName: Binding(
                        get: { sub.name },
                        set: { sub.name = $0 }
                    ),
                    ingredientsItemsQty: Binding(
                        get: { sub.quantity },
                        set: { sub.quantity = $0 }
                    ),
                    onDelete: {
                        withAnimation {
                            ingredient.groupIngredients?.removeAll { $0.id == sub.id }
                        }
                    }
                )
            }
        }
    }
}


#Preview {
    NavigationStack {
        AddManualRecipeView()
    }
    .modelContainer(PreviewContainer.shared)
}
