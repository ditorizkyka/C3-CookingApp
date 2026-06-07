//
//  ButtonAddIngredientsRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct ButtonAddIngredientsRow: View {
    var isGroup: Bool = false
    
    var body: some View {
    
            Button {
                if isGroup {
                    print("tambah Group")
                } else {
                    print("tambah bahan")
                }
            } label: {
                HStack {
                    Image(systemName: AppIcon.plusFill)
                        .foregroundStyle(Color.brandPrimary!)
                    if isGroup {
                        Text("Tambah Grup")
                            .font(.body)
                            .foregroundStyle(Color.brandPrimary!)
                    } else {
                        Text("Tambah Bahan")
                            .font(.body)
                            .foregroundStyle(Color.brandPrimary!)
                    }
                    Spacer()
                }
                .padding(.horizontal,10)
                .background(Color.surfaceBrand)
            }

        
        
    }
}

#Preview {
    VStack(alignment:.leading) {
        ButtonAddIngredientsRow(isGroup: false)
        ButtonAddIngredientsRow(isGroup: true)
    }
}
