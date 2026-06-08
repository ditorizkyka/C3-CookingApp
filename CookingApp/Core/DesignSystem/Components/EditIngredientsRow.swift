//
//  EditIngredientsRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditIngredientsRow: View {
    var isBreakdown : Bool = false
    @State var ingredientsItemsName : String = "5 siung bawang putih"
    
    var body: some View {
        HStack {
            Button {
                print("deleted items ingredients")
            } label: {
                Image(systemName: AppIcon.minusFill)
                    .foregroundStyle(Color.actionDelete!)
            }
            
            if isBreakdown {
                HStack(alignment: .center, spacing: 15) {
                    Circle()
                        .fill(.black)
                        .frame(width: 5, height: 5)
                        .padding(.horizontal,5)
                    
                    TextField("", text: $ingredientsItemsName)
                        .font(.body)
                    
                    Spacer()
                }
            } else {
                TextField("", text: $ingredientsItemsName)
                    .font(.body)
            }
            
            
        
            
            
            Spacer()
            
            Image(systemName: AppIcon.line3Horizontal)
                .font(.body)
                .foregroundStyle(Color.labelLight!) // Mengatur warna

        }
        .padding(.horizontal,10)
    }
}

struct EditIngredientsGroupRow: View {
    @State var ingredientsGroupName : String = "5 siung bawang putih"
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    print("deleted group ingredients")
                } label: {
                    Image(systemName: AppIcon.minusFill)
                        .foregroundStyle(Color.actionDelete!)
                }
                
                TextField("", text: $ingredientsGroupName)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: AppIcon.line3Horizontal)
                    .font(.body)
                    .foregroundStyle(Color.labelLight!)// Mengatur ukuran
                    // Mengatur warna
            }
            

        }
        .padding(.horizontal,10)
    }
}





#Preview {
    VStack(spacing:20) {
        EditIngredientsRow()
        EditIngredientsGroupRow()
        EditIngredientsRow(isBreakdown: true)
    }
}
