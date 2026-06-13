//
//  AddManualRecipeView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddManualRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var recipeTitle: String = ""
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: [Instruction] = []
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
            // ... Keep your properties and header items exactly as they are ...

            // MARK: - Bahan-bahan
            Section(header: Text("Bahan-bahan")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color.labelLight!)
            ) {
                ForEach(ingredients.indices, id: \.self) { index in
                    if ingredients[index].groupIngredients != nil {
                        // Extracted view cleanly passes structural data without timing out the compiler
                        GroupedIngredientSectionView(index: index, ingredients: $ingredients)
                    } else {
                        SingleIngredientSectionView(index: index, ingredients: $ingredients)
                    }
                }
                
                // Add single ingredient
                ButtonAddIngredientsRow(isGroup: false) {
                    let newIngredient = Ingredient(quantity: "", name: "")
                    withAnimation { ingredients.append(newIngredient) }
                }
                .listRowBackground(Color.surfaceBrand)
                
                // Add group
                ButtonAddIngredientsRow(isGroup: true) {
                    let group = Ingredient(
                        quantity: "",
                        name: "",
                        groupIngredients: [
                            Ingredient(quantity: "", name: "")
                        ]
                    )
                    withAnimation { ingredients.append(group) }
                }
                .listRowBackground(Color.surfaceBrand)
            }

            // ... Rest of your instructions, Porsi & Durasi sections stay identical ...
            
            // MARK: - Langkah-langkah
            Section(header: Text("Langkah")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color.labelLight!)
            ) {
                ForEach(instructions.indices, id: \.self) { index in
                        EditInstructionRow(
                            instruction: $instructions[index],
                            onDelete: {
                                withAnimation { _ = instructions.remove(at: index) }
                            }
                        )
                        .listRowSeparator(.hidden)
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
    }
    
    // MARK: - Helpers
    
    /// Check if user has entered any data worth saving
    private var hasUnsavedData: Bool {
        !recipeTitle.isEmpty || !ingredients.isEmpty || !instructions.isEmpty || coverImageData != nil
    }
    
    /// Validate and save the recipe to SwiftData
    private func saveRecipe() {
        // Validate minimum requirements
        guard !recipeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Masukkan nama resep terlebih dahulu."
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
        
        // Save to SwiftData
        modelContext.insert(recipe)
        
        print("✅ Recipe saved: \"\(recipe.title)\" with \(ingredients.count) ingredients, \(instructions.count) instructions")
        
        dismiss()
    }
}

struct SingleIngredientSectionView: View {
    let index: Int
    @Binding var ingredients: [Ingredient]
    
    var body: some View {
        EditIngredientsRow(
            isBreakdown: false,
            ingredientsItemsName: $ingredients[index].name,
            ingredientsItemsQty: $ingredients[index].quantity,
            onDelete: {
                withAnimation { _ = ingredients.remove(at: index) }
            }
        )
    }
}

struct GroupedIngredientSectionView: View {
    let index: Int
    @Binding var ingredients: [Ingredient]
    
    var body: some View {
        if let groupIngredients = ingredients[index].groupIngredients {
            // --- Group Header ---
            HStack {
                Button {
                    withAnimation { _ = ingredients.remove(at: index) }
                } label: {
                    Image(systemName: AppIcon.minusFill)
                        .foregroundStyle(Color.actionDelete!)
                }
                
                TextField("Nama Grup", text: $ingredients[index].name)
                .font(.headline)
                .foregroundColor(Color.labelDark!)
                
                Spacer()
                
                Image(systemName: AppIcon.line3Horizontal)
                    .foregroundStyle(Color.labelLight!)
            }
            .padding(.horizontal, 10)
            .listRowSeparator(.hidden)
            
            // --- Sub-ingredients ---
            ForEach(0..<groupIngredients.count, id: \.self) { subIndex in
                EditIngredientsRow(
                    isBreakdown: true,
                    ingredientsItemsName: Binding(
                        get: { ingredients[index].groupIngredients?[subIndex].name ?? "" },
                        set: { ingredients[index].groupIngredients?[subIndex].name = $0 }
                    ),
                    ingredientsItemsQty: Binding(
                        get: { ingredients[index].groupIngredients?[subIndex].quantity ?? "" },
                        set: { ingredients[index].groupIngredients?[subIndex].quantity = $0 }
                    ),
                    onDelete: {
                        withAnimation {
                            _ = ingredients[index].groupIngredients?.remove(at: subIndex)
                        }
                    }
                )
            }
            
            // Add sub-ingredient button
            Button {
                let newSub = Ingredient(quantity: "", name: "")
                withAnimation {
                    if ingredients[index].groupIngredients == nil {
                        ingredients[index].groupIngredients = []
                    }
                    ingredients[index].groupIngredients?.append(newSub)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: AppIcon.plusFill)
                        .foregroundStyle(Color.brandPrimary!)
                    Text("Tambah Bahan ke Grup")
                        .font(.caption)
                        .foregroundStyle(Color.brandPrimary!)
                }
                .padding(.leading, 30)
            }
            .buttonStyle(.plain)
        }
    }
}


#Preview {
    NavigationStack {
        AddManualRecipeView()
    }
    .modelContainer(PreviewContainer.shared)
}
