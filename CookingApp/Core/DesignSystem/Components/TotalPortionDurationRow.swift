//
//  TotalPortionDurationRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct TotalPortionRow: View {
    let portionOptions = [1, 2, 3, 4, 5, 6, 8, 10]
    @Binding var selectedPortion: Int
    
    var body: some View {
        HStack {
            Text("Jumlah Porsi")
                .font(.body)
                .foregroundStyle(Color.labelLight!)
            Spacer()
            Picker("", selection: $selectedPortion) {
                ForEach(portionOptions, id: \.self) { portion in
                    Text("\(portion) Orang").tag(portion)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.labelDark!)
        }
        .padding(.horizontal, 10)
    }
}

struct TotalDurationRow: View {
    let durationOptions = [5, 10, 15, 30, 45, 60, 90, 120]
    @Binding var selectedDuration: Int
    
    var body: some View {
        HStack {
            Text("Lama Memasak")
                .font(.body)
                .foregroundStyle(Color.labelLight!)
            Spacer()
            Picker("", selection: $selectedDuration) {
                ForEach(durationOptions, id: \.self) { duration in
                    Text("\(duration) Menit").tag(duration)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.labelDark!)
        }
        .padding(.horizontal, 10)
    }
}


#Preview {
    @Previewable @State var portion = 1
    @Previewable @State var duration = 10
    
    VStack {
        TotalPortionRow(selectedPortion: $portion)
        TotalDurationRow(selectedDuration: $duration)
    }
}
