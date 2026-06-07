//
//  AddManualRecipeView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct AddManualRecipeView: View {
    var body: some View {
        NavigationStack {
            List {
                VStack {
                    EditAddHeaderRecipe()
                   
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                Section(header: Text("Bahan-bahan").font(.body).fontWeight(.semibold).foregroundColor(.labelLight)) {
                    
                    EditIngredientsRow()
                    
                    // Row 1: Tambah Grup
                    ButtonAddIngredientsRow(isGroup: true)
                        .listRowBackground(Color.surfaceBrand)
                        
                    
                    // Row 2: Tambah Bahan
                    ButtonAddIngredientsRow(isGroup: false)
                        .listRowBackground(Color.surfaceBrand)
//
                }
                
                Section(header: Text("Langkah").font(.body).fontWeight(.semibold).foregroundColor(.labelLight)) {
                    
                    EditInstructionRow()
                        
                    ButtonAddInstructions()
                        .listRowBackground(Color.surfaceBrand)
                    
                }
                
                Section() {
                    TotalPortionRow()
                    TotalDurationRow()
                    
                }
                
                ButtonApp(title: "Simpan",action: { print("save")})
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
            }
            // Set background langsung di ScrollView
            .background(Color.surfaceDefault)
            
            
        }
        .toolbarRole(.editor)
        
        
    }
    
}

#Preview {
    AddManualRecipeView()
}
