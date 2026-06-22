//
//  EmptyStateView.swift
//  CookingApp
//
//  Created by Brian Anashari on 07/06/26.
//

import SwiftUI

struct HomeEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: "book.pages.fill")
                .font(Font.xLargeTitle)
                .padding(13)
                .foregroundStyle(Color.brandPrimary)
                .background(Color.brandPrimary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: Radius.infinity))
            
            // Content
            VStack(spacing: 8) {
                // Title
                Text("Siapkan Resep dan Mulai Masak")
                    .font(Font.largeTitle)
                
                // Subtitle
                Text("Mulai buat resep. Coba memasak dengan panduan suara!")
                    .font(Font.headline)
                    .foregroundStyle(Color.labelLight)
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [8, 8]))
                .foregroundColor(Color.brandPrimary)
        )
    }
}

#Preview {
    HomeEmptyStateCard()
}
