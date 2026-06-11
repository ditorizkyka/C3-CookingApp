//
//  ClipboardToastView.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 10/06/26.
//

import SwiftUI

struct ClipboardToastView: View {
    let url: String
    let onImport: () -> Void
    let onDismiss: () -> Void
    
    /// Shows just the host (e.g. "cookpad.com") for a nicer subtitle.
    private var displayHost: String {
        URL(string: url)?.host ?? url
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Icon
            Image(systemName: "link.badge.plus")
                .font(.title2)
                .foregroundStyle(Color.brandPrimary!)
            
            // MARK: - Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Link Terdeteksi")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(displayHost)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // MARK: - Import Button
            Button(action: onImport) {
                Text("Import")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.labelLightest!)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brandPrimary!)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        // Swipe down to dismiss
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height > 20 {
                        onDismiss()
                    }
                }
        )
    }
}

#Preview {
    ZStack {
        Color.surfaceDefault.ignoresSafeArea()
        VStack {
            Spacer()
            ClipboardToastView(
                url: "https://cookpad.com/id/resep/25666403",
                onImport: { print("import") },
                onDismiss: { print("dismiss") }
            )
            .padding(.bottom, 20)
        }
    }
}