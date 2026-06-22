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
                
                Rectangle()
                    .fill(Color.labelDark)
                    .frame(height: 1)
                
                // Description
                Text(LocalizedStringKey(guide.description))
                    .font(Font.body)
            }
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .glassEffect(in: RoundedRectangle(cornerRadius: Radius.large))
    }
}

#Preview {
    GuideCard(guide: Guide(icon: "forward.fill", title: "Pindah Langkah", description: "Katakan **\"Lanjut\"** untuk beralih ke instruksi selanjutnya"))
}
