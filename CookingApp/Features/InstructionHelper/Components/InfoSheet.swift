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
        VStack(spacing: 16) {
            // Sheet Title
            VStack {
                Text("Perintah Suara")
                    .font(Font.title)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 7)
                
                Text("Gunakan perintah suara berikut untuk mengontrol langkah memasak tanpa menyentuh layar")
                    .font(Font.footnote)
                    .foregroundStyle(Color.labelLight)
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
