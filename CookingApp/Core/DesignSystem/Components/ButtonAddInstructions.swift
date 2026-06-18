//
//  ButtonAddInstructions.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct ButtonAddInstructions: View {
    var action: (() -> Void)? = nil
    
    var body: some View {
        
        Button { 
            action?()
        } label: {
            HStack {
                Image(systemName: AppIcon.plusFill)
                    .foregroundStyle(Color.brandPrimary)
                Text("Tambah Langkah")
                    .font(.body)
                    .foregroundStyle(Color.brandPrimary)
                Spacer()
            }
            .padding(.horizontal,10)
            .background(Color.surfaceBrand)
        }
    }
}

#Preview {
    ButtonAddInstructions()
}
