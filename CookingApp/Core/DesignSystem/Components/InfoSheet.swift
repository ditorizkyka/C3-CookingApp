//
//  InstuctionHelperSheet.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct InfoSheet: View {
    var guides = [
        Guide(icon: "forward.fill", title: "Pindah Langkah", description: "Katakan **\"Lanjut\"** untuk beralih ke instruksi selanjutnya"),
        Guide(icon: "backward.fill", title: "Kembali ke Sebelumnya", description: "Katakan **\"Kembali\"** untuk melihat ulang instruksi sebelumnya"),
        Guide(icon: "repeat", title: "Dengarkan Ulang", description: "Katakan **\"Ulangi\"** untuk mendengar ulang instruksi saat ini")
    ]
    
    var body: some View {
        VStack {
            // Sheet Title
            VStack {
                Image(systemName: "waveform.badge.microphone")
                    .font(Font.xXXLargeTitle)
                    .foregroundStyle(Color.brandPrimary!)
                
                Text("Masak Praktis Lewat Suara")
                    .font(Font.largeTitle)
                    .multilineTextAlignment(.center)
            }
            
            // Content
            VStack {
                ForEach(guides, id: \.title) { guide in
                        GuideCard(guide: guide)
                }
            }
        }
        .padding()
    }
}

#Preview {
    InfoSheet()
}
