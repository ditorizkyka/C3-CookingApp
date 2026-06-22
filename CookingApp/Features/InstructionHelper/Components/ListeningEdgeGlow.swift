//
//  ListeningEdgeGlow.swift
//  CookingApp
//
//  Created by Brian Anashari on 18/06/26.
//

import SwiftUI

struct ListeningEdgeGlow: View {
    var isListening: Bool
    var isSpeaking: Bool

    @State private var pulse: CGFloat = 1.0
    @State private var shimmer: CGFloat = 0.0

    private var activeColor: Color? {
//        if isListening { return Color.ovalGreen }
        if isSpeaking  { return Color.brandSecondary }
        return nil
    }

    var body: some View {
        GeometryReader { geo in
            if let color = activeColor {
                ZStack {
                    RoundedRectangle(cornerRadius: 44, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: color.opacity(0.0),            location: 0.0),
                                    .init(color: color.opacity(0.6 * pulse),    location: 0.25),
                                    .init(color: color.opacity(0.85 * pulse),   location: 0.5),
                                    .init(color: color.opacity(0.6 * pulse),    location: 0.75),
                                    .init(color: color.opacity(0.0),            location: 1.0),
                                ]),
                                startPoint: UnitPoint(x: shimmer, y: 0),
                                endPoint:   UnitPoint(x: 1 - shimmer, y: 1)
                            ),
                            lineWidth: 24
                        )
                        .blur(radius: 12)

                    RoundedRectangle(cornerRadius: 44, style: .continuous)
                        .stroke(color.opacity(0.25 * pulse), lineWidth: 40)
                        .blur(radius: 24)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .transition(.opacity)
                .onAppear {
                    startAnimations()
                }
                .onChange(of: isListening) { _, _ in startAnimations() }
                .onChange(of: isSpeaking)  { _, _ in startAnimations() }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.5), value: isListening)
        .animation(.easeInOut(duration: 0.5), value: isSpeaking)
    }

    private func startAnimations() {
        // Reset
        pulse = 1.0
        shimmer = 0.0

        if isListening {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = 0.45
            }
        } else if isSpeaking {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmer = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = 0.6
            }
        }
    }
}

#Preview("Listening State") {
    ZStack {
        Color.black.ignoresSafeArea()
        ListeningEdgeGlow(isListening: true, isSpeaking: false)
    }
}

#Preview("Speaking State") {
    ZStack {
        Color.black.ignoresSafeArea()
        ListeningEdgeGlow(isListening: false, isSpeaking: true)
    }
}
