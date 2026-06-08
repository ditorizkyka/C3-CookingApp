//
//  NavigationControlsView.swift
//  CookingApp
//
//  Created by Brian Anashari on 08/06/26.
//

import SwiftUI

struct NavigationControlsView: View {
    var currentPage: Int
    var totalPages: Int
    var onPrevious: () -> Void
    var onNext: () -> Void
    
    private var visibleIndices: [Int] {
        if totalPages <= 5 {
            return Array(0..<totalPages)
        }
        
        if currentPage <= 2 {
            return Array(0..<5)
        } else if currentPage >= totalPages - 3 {
            return Array((totalPages - 5)..<totalPages)
        } else {
            return Array((currentPage - 2)...(currentPage + 2))
        }
    }
    
    var body: some View {
        HStack {
            // Tombol Back (Kiri)
            Button {
                onPrevious()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(16)
                    .background(Color.brandPrimary!)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(visibleIndices, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.black : Color.gray.opacity(0.5))                        
                        .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            
            Spacer()
            
            // Tombol Next (Kanan)
            Button {
                onNext()
            } label: {
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(16)
                    .background(Color.brandPrimary!)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
