//
//  TotalPortionDurationRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct TotalPortionRow: View {
    let portionOptions = [0, 1, 2, 3, 4, 5, 6, 8, 10, 11]
    @Binding var selectedPortion: Int
    
    var body: some View {
        HStack {
            Text("Jumlah Porsi")
                .font(.body)
                .foregroundStyle(Color.labelLight)
            Spacer()
            Picker("", selection: $selectedPortion) {
                ForEach(portionOptions, id: \.self) { portion in
                    if portion == 0 {
                        Text("Tidak tahu").tag(portion)
                    } else if portion == 11 {
                        Text("Lebih dari 10 Orang").tag(portion)
                    } else {
                        Text("\(portion) Orang").tag(portion)
                    }
                }
            }
            .pickerStyle(.menu)
            .tint(Color.labelDark)
        }
        .padding(.horizontal, 10)
    }
}

struct TotalDurationRow: View {
    let durationOptions = [5, 10, 15, 30, 45, 60, 90, 120, 121]
    @Binding var selectedDuration: Int
    
    var body: some View {
        HStack {
            Text("Lama Memasak")
                .font(.body)
                .foregroundStyle(Color.labelLight)
            Spacer()
            Picker("", selection: $selectedDuration) {
                ForEach(durationOptions, id: \.self) { duration in
                    if duration == 121 {
                        Text("> 120 Menit").tag(duration)
                    } else {
                        Text("\(duration) Menit").tag(duration)
                    }
                }
            }
            .pickerStyle(.menu)
            .tint(Color.labelDark)
        }
        .padding(.horizontal, 10)
    }
}

struct RecipeCategoryRow: View {
    @Binding var selectedCategory: RecipeCategory
    
    var body: some View {
        HStack {
            Text("Kategori")
                .font(.body)
                .foregroundStyle(Color.labelLight)
            Spacer()
            Picker("", selection: $selectedCategory) {
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    Text("\(category.icon) \(category.rawValue)").tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.labelDark)
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    @Previewable @State var portion = 1
    @Previewable @State var duration = 10
    @Previewable @State var category: RecipeCategory = .lainnya
    
    VStack {
        TotalPortionRow(selectedPortion: $portion)
        TotalDurationRow(selectedDuration: $duration)
        RecipeCategoryRow(selectedCategory: $category)
    }
}
