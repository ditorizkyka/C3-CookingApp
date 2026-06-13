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

            dragHandle
        }
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    private var dragHandle: some View {
        let handle = Image(systemName: AppIcon.line3Horizontal)
            .font(.body)
            .foregroundStyle(Color.labelLight!)

        if let onDrag {
            handle.onDrag(onDrag)
        } else {
            handle
        }
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
                
                Image(systemName: AppIcon.line3Horizontal)
                    .font(.body)
                    .foregroundStyle(Color.labelLight!)
            }
        }
    }
}


#Preview {
    @Previewable @State var name = "Bawang Merah"
    @Previewable @State var qty = "10 siung"
    @Previewable @State var ingredients: [Ingredient] = []
    
    VStack(spacing: 20) {
        EditIngredientsRow(isBreakdown: true, ingredientsItemsName: $name, ingredientsItemsQty: $qty)
        EditIngredientsRow(isBreakdown: false, ingredientsItemsName: $name, ingredientsItemsQty: $qty)
    }
}
