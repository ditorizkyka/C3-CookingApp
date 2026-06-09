import SwiftUI

struct VoiceCommandGuideCard: View {
    var guides: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "info.circle")
                Text("Petunjuk Perintah Suara")
            }
            
            ForEach(guides.sorted(by: >), id: \.key) { guide in
                HStack {
                    Text("• **‘\(guide.key)’** : ")
                    Text(guide.value)
                }
            }
        }
        .font(Font.footnote)
        .foregroundStyle(Color.labelLight ?? .white)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.surfaceElevated ?? .gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.medium)
                .stroke(style: StrokeStyle(lineWidth: 1))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VoiceCommandGuideCard(guides: [
            "Lanjut": "Langkah Berikutnya",
            "Ulangi": "Langkah Saat Ini",
            "Balik": "Langkah Sebelumnya"
        ])
    }
}
