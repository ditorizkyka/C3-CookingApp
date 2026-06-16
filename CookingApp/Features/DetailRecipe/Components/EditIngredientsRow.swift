//
//  EditIngredientsRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditIngredientsRow: View {
    var isBreakdown: Bool = false
    @Binding var ingredientsItemsName: String
    @Binding var ingredientsItemsQty: String
    var onDelete: (() -> Void)? = nil
    /// When set, the ☰ handle becomes a drag source (for live reordering).
    var onDrag: (() -> NSItemProvider)? = nil

    var body: some View {
        HStack {
            DeleteConfirmButton {
                onDelete?()
            }

            if isBreakdown {
                HStack(alignment: .center) {
                    Circle()
                        .fill(Color.labelDark!)
                        .frame(width: 3, height: 3)
                        .padding(.horizontal, 5)
                    
                    TextField("Jumlah", text: $ingredientsItemsQty)
                        .font(.body)
                        .frame(width: 65)
                
                    
                    TextField("Nama Bahan", text: $ingredientsItemsName)
                        .font(.body)
                    
                    Spacer()
                }
            } else {
                HStack(spacing: 8) {
                    TextField("Jumlah", text: $ingredientsItemsQty)
                        .font(.body)
                        .frame(width: 65)
                    
                    TextField("Nama Bahan", text: $ingredientsItemsName)
                        .font(.body)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }

}

struct EditIngredientsGroupRow: View {
    @Binding var ingredients: [Ingredient]
    
    var body: some View {
        ForEach($ingredients) { $ingredient in
            HStack {
                Button {
                    print("deleted group")
                } label: {
                    Image(systemName: AppIcon.minusFill)
                        .foregroundStyle(Color.actionDelete!)
                }
                
                TextField("Nama Grup", text: $ingredient.name)
                    .font(.headline)
                
                Spacer()
            }
        }
    }
}


#Preview {
    @Previewable @State var name = "Bawang Merah"
    @Previewable @State var qty = "10 siung"
    @Previewable @State var subName = "Garam"
    @Previewable @State var subQty = "Secukupnya"
    @Previewable @State var ingredients: [Ingredient] = [
        Ingredient(quantity: "", name: "Bumbu Halus")
    ]
    
    List {
        Section("Bahan Satuan") {
            EditIngredientsRow(isBreakdown: false, ingredientsItemsName: $name, ingredientsItemsQty: $qty)
        }
        
        Section("Bahan Grup") {
            EditIngredientsGroupRow(ingredients: $ingredients)
            EditIngredientsRow(isBreakdown: true, ingredientsItemsName: $subName, ingredientsItemsQty: $subQty)
        }
    }
}
