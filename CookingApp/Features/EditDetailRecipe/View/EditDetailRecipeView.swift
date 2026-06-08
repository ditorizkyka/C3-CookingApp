//
//  EditDetailRecipeView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 08/06/26.
//

import SwiftUI


struct EditDetailRecipeView: View {
   
    @State var editRecipeData: Recipe = Recipe.dummyRecipes[0]
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Header (Image + Title)
                VStack {
                    EditAddHeaderRecipe(
                        titleRecipe: $editRecipeData.title
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                // MARK: - Bahan-bahan
                Section(header: Text("Bahan-bahan")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLight!)
                ) {
                    ForEach($editRecipeData.ingredients) { $ingredient in
                        
                        if ingredient.groupIngredients != nil {
                            
                            HStack {
                                Button {
                                    print("deleted group")
                                } label: {
                                    Image(systemName: AppIcon.minusFill)
                                        .foregroundStyle(Color.actionDelete!)
                                }
                                
                                TextField("Nama Grup", text: $ingredient.name)
                                    .font(.headline)
                                    .foregroundColor(Color.labelDark!)
                                    .padding(.top, 8)
                                    .padding(.bottom, 2)
                                
                                Spacer()
                                
                                Image(systemName: AppIcon.line3Horizontal)
                                    .font(.body)
                                    .foregroundStyle(Color.labelLight!)
                            }
                            .padding(.horizontal, 10)
                            .listRowSeparator(.hidden)
                            
                            if let _ = ingredient.groupIngredients {
                                ForEach($ingredient.groupIngredients.bound()) { $subIngredient in
                                    EditIngredientsRow(
                                        isBreakdown: true,
                                        ingredientsItemsName: $subIngredient.name,
                                        ingredientsItemsQty: $subIngredient.quantity
                                    )
                                }
                            }
                            
                        } else {
                            EditIngredientsRow(
                                isBreakdown: false,
                                ingredientsItemsName: $ingredient.name,
                                ingredientsItemsQty: $ingredient.quantity
                            )
                        }
                    }
                    
                    ButtonAddIngredientsRow(isGroup: true)
                        .listRowBackground(Color.surfaceBrand)
                        
                    ButtonAddIngredientsRow(isGroup: false)
                        .listRowBackground(Color.surfaceBrand)
                }
                
                // MARK: - Langkah-langkah
                Section(header: Text("Langkah")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLight!)
                ) {
                    ForEach($editRecipeData.instructions) { $instruction in
                        EditInstructionRow(instruction: $instruction)
                    }
                        
                    ButtonAddInstructions()
                        .listRowBackground(Color.surfaceBrand)
                }
                
                // MARK: - Porsi & Durasi
                Section {
                    TotalPortionRow(selectedPortion: $editRecipeData.portion)
                    TotalDurationRow(selectedDuration: $editRecipeData.durationInMinutes)
                }
                
                // MARK: - Simpan
                ButtonApp(title: "Simpan", action: { print("save") })
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
            }
            .background(Color.surfaceDefault)
        }
        .toolbarRole(.editor)
    }
}

// MARK: - Binding Helper for Optional Arrays
extension Binding where Value == [Ingredient]? {
    func bound() -> Binding<[Ingredient]> {
        Binding<[Ingredient]>(
            get: { self.wrappedValue ?? [] },
            set: { self.wrappedValue = $0 }
        )
    }
}

#Preview {
    EditDetailRecipeView()
}
