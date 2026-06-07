//
//  TotalPortionDurationRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct TotalPortionRow: View {
    let categories = ["1 Orang", "2 Orang", "3 Orang", "4 Orang", "5 Orang", "6-10 Orang", "lebih dari 10 Orang"]
    
    
    @State private var selectedCategory = "1 Orang"
    
    var body: some View {
        HStack {
            Text("Jumlah Porsi")
                .font(.body)
                .foregroundStyle(Color.labelLight!)
            Spacer()
            // 3. Membuat Picker
            Picker("", selection: $selectedCategory) {
                // Looping data kategori
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
//            .accentColor(Color.black)
            .pickerStyle(.menu)
            .tint(.black)
            
        }
        .padding(.horizontal,10)
        
    }
    
}

struct TotalDurationRow: View {
    let categories = ["5 Menit", "10 Menit", "15 Menit", "30 Menit", "45 Menit", "60 Menit", "Lebih Dari 60 Menit"]
    
    
    @State private var selectedCategory = "5 Menit"
    
    var body: some View {
        HStack {
            Text("Jumlah Durasi")
                .font(.body)
                .foregroundStyle(Color.labelLight!)
            Spacer()
            // 3. Membuat Picker
            Picker("", selection: $selectedCategory) {
                // Looping data kategori
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
//            .accentColor(Color.black)
            .pickerStyle(.menu)
            .tint(.black)
            
        }
        .padding(.horizontal,10)
        
    }
    
}



#Preview {
    TotalPortionRow()
    TotalDurationRow()
}
