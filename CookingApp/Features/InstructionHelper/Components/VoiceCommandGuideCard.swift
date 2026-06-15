import SwiftUI

struct VoiceCommandGuideCard: View {
    var guides: [String: String]
    
    private let guideOrder = ["Kembali", "Ulangi", "Lanjut"]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Petunjuk Perintah Suara")
                .font(Font.subheadline)
            
            HStack(spacing: 0) {
                let orderedKeys = guideOrder.filter { guides.keys.contains($0) }
                let otherKeys = guides.keys.filter { !guideOrder.contains($0) }.sorted()
                let allKeys = orderedKeys + otherKeys
                
                ForEach(Array(allKeys.enumerated()), id: \.element) { index, key in
                    VStack(spacing: 6) {
                        Text("‘\(key)’")
                            .font(.footnote)
                            .bold()
                        
                        Text(guides[key] ?? "")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .opacity(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    if index < allKeys.count - 1 {
                        Divider()
                            .frame(height: 35)
                            .overlay(Color.labelLight?.opacity(0.3) ?? .gray.opacity(0.3))
                    }
                }
            }
        }
        .foregroundStyle(Color.labelLight!)
        .padding(15)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VoiceCommandGuideCard(guides: [
            "Kembali": "Langkah Sebelumnya",
            "Ulangi": "Langkah Saat Ini",
            "Lanjut": "Langkah Berikutnya",
        ])
    }
}
