//
//  MicAndGuideView.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct MicAndGuideView: View {
    var guides: [String: String]
    var onHide: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Microphone
            HStack {
                Image(systemName: "wave.3.left")
                    .font(Font.title)
                Image(systemName: "microphone.fill")
                    .font(Font.largeTitle)
                Image(systemName: "wave.3.right")
                    .font(Font.title)
            }
            .foregroundStyle(Color.brandPrimary!)
            .fontWeight(.regular)
            
            // Guide
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
                
                // Hide
                Button {
                    onHide()
                } label: {
                    Text("Sembunyikan")
                        .underline()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.brandPrimary!)
            }
            .font(Font.footnote)
            .foregroundStyle(Color.labelLight!)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .stroke(style: StrokeStyle(lineWidth: 1))
            )
        }
    }
}
