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
    var onRepeat: () -> Void
    var onComplete: (() -> Void)? = nil
    
    private var isLastStep: Bool {
        totalPages > 0 && currentPage == totalPages - 1
    }
    
    var body: some View {
        HStack {
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
            
            Button {
                onRepeat()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Ulangi")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Color.brandPrimary ?? .green)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassEffect()
                .clipShape(Capsule())
            }
            
            Spacer()
            
            Button {
                if isLastStep {
                    onComplete?()
                } else {
                    onNext()
                }
            } label: {
                Image(systemName: isLastStep ? "checkmark" : "arrow.right")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(16)
                    .background(isLastStep ? Color.brandAccent! : Color.brandPrimary!)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.2), value: isLastStep)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
