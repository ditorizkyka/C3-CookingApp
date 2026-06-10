//
//  InstructionSheetContentCard.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct Guide: Hashable {
    let icon: String
    let title: String
    let description: String
}

struct GuideCard: View {
    var guide: Guide
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: guide.icon)
                .font(Font.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                // Instruction Title
                Text(guide.title)
                    .font(Font.headline)
                
                Divider()
                    .foregroundStyle(Color.labelLight!)
                
                // Description
                Text(LocalizedStringKey(guide.description))
                    .font(Font.body)
            }
        }
        .padding(16)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.medium)
                .stroke(Color.brandPrimary!, lineWidth: 1)
        )
    }
}

#Preview {
    GuideCard(guide: Guide(icon: "forward.fill", title: "Pindah Langkah", description: "Katakan **\"Lanjut\"** untuk beralih ke instruksi selanjutnya"))
}
