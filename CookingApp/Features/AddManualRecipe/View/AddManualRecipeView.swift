//
//  AddManualRecipeView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct AddManualRecipeView: View {
    @State var newRecipeData: Recipe = Recipe(
        id: UUID(),
        title: "",
        author: Author(id: UUID(), name: "", username: "", avatarUrl: nil),
        coverImageUrl: nil,
        portion: 1,
        durationInMinutes: 10,
        ingredients: [],
        instructions: [],
        tips: nil
    )
    
    var body: some View {
        NavigationStack {
            List {
                VStack {
                    EditAddHeaderRecipe(
                        titleRecipe: $newRecipeData.title
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                Section(header: Text("Bahan-bahan")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLight!)
                ) {
                    ForEach($newRecipeData.ingredients) { $ingredient in
                        EditIngredientsRow(
                            isBreakdown: false,
                            ingredientsItemsName: $ingredient.name,
                            ingredientsItemsQty: $ingredient.quantity
                        )
                    }
                    
                    ButtonAddIngredientsRow(isGroup: true)
                        .listRowBackground(Color.surfaceBrand)
                    
                    ButtonAddIngredientsRow(isGroup: false)
                        .listRowBackground(Color.surfaceBrand)
                }
                
                Section(header: Text("Langkah")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLight!)
                ) {
                    ForEach($newRecipeData.instructions) { $instruction in
                        EditInstructionRow(instruction: $instruction)
                    }
                        
                    ButtonAddInstructions()
                        .listRowBackground(Color.surfaceBrand)
                }
                
                Section {
                    TotalPortionRow(selectedPortion: $newRecipeData.portion)
                    TotalDurationRow(selectedDuration: $newRecipeData.durationInMinutes)
                }
                
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

#Preview {
    AddManualRecipeView()
}
